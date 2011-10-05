require 'fileutils'
require 'nokogiri'
require 'tempfile'
require 'xml/xslt'
include ActionView::Helpers::NumberHelper

class NoImageDescriptions < Exception
end

class NonDaisyXMLException < Exception
end

class MissingBookUIDException < Exception
end

class ShowAlertAndGoBack < Exception
  def initialize(message)
    @message = message
  end
  
  attr_reader :message
end

class DaisyBookController < ApplicationController
  include S3Repository

  ROOT_XPATH = "/xmlns:dtbook"
  
  def submit_to_get_descriptions
    book = params[:book]
    password = params[:password]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'process'
      return
    end

    if password && !password.empty?
      begin
        Zip::Archive.decrypt(book.path, password)
      rescue Zip::Error => e
        logger.info "#{e.class}: #{e.message}"
        if e.message.include?("Wrong password")
          logger.info "#{caller_info} Invalid Password for encyrpted zip"
          flash[:alert] = "Please check your password and re-enter"
        else
          logger.info "#{caller_info} Other problem with encrypted zip"
          flash[:alert] = "There is a problem with this zip file"
        end
        redirect_to :action => 'upload'
        return
      end
    end

    if !valid_daisy_zip?(book.path)
      flash[:alert] = "Not a valid DAISY book"
      redirect_to :action => 'process'
      return
    end
    
    begin
      accept_book(book.path)
      redirect_to :action => 'get_daisy_with_descriptions'
    rescue Zip::Error => e
      logger.info "#{e.class}: #{e.message}"
      if e.message.include?("File encrypted")
        logger.info "#{caller_info} Password needed for zip"
        flash[:alert] = "Please enter a password for this book"
      else
        logger.info "#{caller_info} Other problem with zip"
        flash[:alert] = "There is a problem with this zip file"
      end

      redirect_to :action => 'upload'
      return
    end
  end
  
  def get_daisy_with_descriptions
    begin
      book_directory = session[:daisy_directory]
      zip_directory = session[:zip_directory]
      contents_filename = get_daisy_contents_xml_name(book_directory)
      relative_contents_path = contents_filename[zip_directory.length..-1]
      if(relative_contents_path[0,1] == '/')
        relative_contents_path = relative_contents_path[1..-1]
    end
      xml = get_xml_contents_with_updated_descriptions(contents_filename)
      zip_filename = create_zip(session[:daisy_file], relative_contents_path, xml)    
      basename = File.basename(contents_filename)
      logger.info "Sending zip #{zip_filename} of length #{File.size(zip_filename)}"
      send_file zip_filename, :type => 'application/zip; charset=utf-8', :filename => basename + '.zip', :disposition => 'attachment' 
    rescue ShowAlertAndGoBack => e
      flash[:alert] = e.message
      redirect_to :action => 'upload'
      return
    end
  end
  
  def get_xml_with_descriptions
    begin
      book_directory = session[:daisy_directory]
      zip_directory = session[:zip_directory]
      contents_filename = get_daisy_contents_xml_name(book_directory)
      xml = get_xml_contents_with_updated_descriptions(contents_filename)
      send_data xml, :type => 'application/xml; charset=utf-8', :filename => contents_filename, :disposition => 'attachment' 
    rescue ShowAlertAndGoBack => e
      redirect_to :back, :alert => e.message
      return
    end
  end

  def get_xml_contents_with_updated_descriptions(contents_filename)
    xml_file = File.read(contents_filename)
    begin
      xml = get_contents_with_updated_descriptions(xml_file)
    rescue NoImageDescriptions
      logger.info "#{caller_info} No descriptions available #{contents_filename}"
      raise ShowAlertAndGoBack.new("There are no image descriptions available for this book")
    rescue NonDaisyXMLException => e
      logger.info "#{caller_info} Uploaded non-dtbook #{contents_filename}"
      raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
    rescue MissingBookUIDException => e
      logger.info "#{caller_info} Uploaded dtbook without UID #{contents_filename}"
      raise ShowAlertAndGoBack.new("Uploaded Daisy book XML content file must have a UID element")
    rescue Nokogiri::XML::XPath::SyntaxError => e
      logger.info "#{caller_info} Uploaded invalid XML file #{contents_filename}"
      logger.info "#{e.class}: #{e.message}"
      logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
      raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
    rescue Exception => e
      logger.info "#{caller_info} Unexpected exception processing #{contents_filename}:"
      logger.info "#{e.class}: #{e.message}"
      logger.info e.backtrace.join("\n")
      $stderr.puts e
      raise ShowAlertAndGoBack.new("An unexpected error has prevented processing that file")
    end
    
    return xml
  end


  def accept_book(book_path)
    zip_directory = unzip_to_temp(book_path)
    session[:zip_directory] = zip_directory
    top_level_entries = Dir.entries(zip_directory)
    top_level_entries.delete('.')
    top_level_entries.delete('..')
    if(top_level_entries.size == 1)
      book_directory = File.join(zip_directory, top_level_entries.first)
    else
      book_directory = zip_directory
    end
    session[:daisy_directory] = book_directory

    copy_of_daisy_file = File.join(zip_directory, "Daisy.zip")
    FileUtils.cp(book_path, copy_of_daisy_file)
    session[:daisy_file] = copy_of_daisy_file
      
    return book_directory
  end
  
  def file
    directory_name = params[:directory]
    if !directory_name
      directory_name = ''
    end
    file_name = params[:file]
    book_directory = ENV['POET_LOCAL_STORAGE_DIR']

    directory = File.join(book_directory, directory_name)
    file = File.join(directory, file_name)
    timestamp = File.stat(file).ctime
    if(stale?(:last_modified => timestamp))
      content_type = 'text/plain'
      case File.extname(file).downcase
      when '.jpg', '.jpeg'
        content_type = 'image/jpeg'
      when '.png'
        content_type = 'image/png'
      end
      contents = File.read(file)
      response.headers['Last-Modified'] = timestamp.httpdate
      render :text => contents, :content_type => content_type
    end
  end
    
  def valid_daisy_zip?(file)
    begin
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.name =~ /\.ncx$/
            return true
          end
        end
      end
    rescue Zip::Error => e
        logger.info "#{e.class}: #{e.message}"
        if e.message.include?("Not a zip archive")
            logger.info "#{caller_info} Not a ZIP File"
            flash[:alert] = "Uploaded file must be a valid Daisy (zip) file"
        else
            logger.info "#{caller_info} Other problem with zip"
            flash[:alert] = "There is a problem with this zip file"
        end
        puts e
        puts e.backtrace.join("\n")
        return false
    end
    flash[:alert] = "Uploaded file must be a valid Daisy (zip) file"
    return false
  end
  
  def extract_book_uid(doc)
    xpath_uid = "//xmlns:meta[@name='dtb:uid']"
    matches = doc.xpath(doc, xpath_uid)
    if matches.size != 1
      raise MissingBookUIDException.new
    end
    node = matches.first
    return node.attributes['content'].content
  end


  def get_description_count_for_book(book_uid)
    return DynamicImage.
        joins(:dynamic_descriptions).
        where("dynamic_images.book_uid = ?", book_uid).
        count
  end
  
private
  def unzip_to_temp(zipped_file)
    dir = Dir.mktmpdir
    Zip::Archive.open(zipped_file) do |zipfile|
      zipfile.each do |entry|
        destination = File.join(dir, entry.name)
        if entry.directory?
          FileUtils.mkdir_p(destination)
        else
          dirname = File.join(dir, File.dirname(entry.name))
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
          open(destination, 'wb') do |f|
            f << entry.read
          end
        end
      end
    end    
    return dir
  end
  
  def get_daisy_contents_xml_name(book_directory)
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end

  def get_contents_with_updated_descriptions(file)
    doc = Nokogiri::XML file
    
    root = doc.xpath(doc, ROOT_XPATH)
    if root.size != 1
      raise NonDaisyXMLException.new
    end
  
    book_uid = extract_book_uid(doc)
  
    if get_description_count_for_book(book_uid) == 0
      raise NoImageDescriptions.new
    end
    
    matching_images = DynamicImage.where("book_uid = ?", book_uid)
    matching_images.each do | dynamic_image |
      image_location = dynamic_image.image_location
      image = doc.at_xpath( doc, "//xmlns:img[@src='#{image_location}']")
      if !image
        logger.info "Missing img element for database description #{book_uid} #{image_location}"
        next
      end

      dynamic_description = dynamic_image.best_description
      if(!dynamic_description)
        logger.info "Image #{book_uid} #{image_location} is in database but with no descriptions"
        next
      end

      parent = image.at_xpath("..")
      imggroup = get_imggroup_parent_of(image)
      if(!imggroup)
        imggroup = Nokogiri::XML::Node.new "imggroup", doc
        imggroup.parent = parent
        
        parent.children.delete(image)
        image.parent = imggroup
        parent = imggroup
      end
  
      image_id = image['id']
  
      prodnotes = imggroup.xpath(".//xmlns:prodnote")
      our_prodnote = nil
      prodnotes.each do | prodnote |
        if(prodnote['id'] == create_prodnote_id(image_id))
          our_prodnote = prodnote
        end
      end
      if(!our_prodnote)
        our_prodnote = Nokogiri::XML::Node.new "prodnote", doc 
        imggroup.add_child our_prodnote 
      end
      
      our_prodnote.add_child(dynamic_description.body)
      our_prodnote['render'] = 'optional'
      our_prodnote['imgref'] = image_id
      our_prodnote['id'] = create_prodnote_id(image_id)
      our_prodnote['showin'] = 'blp'
    end
    
    return doc.to_xml
  end
  
  def get_imggroup_parent_of(image_node)
    node = image_node
    prevent_infinite_loop = 100
    while(node)
      if(node.node_name == "imggroup")
        return node
      end
      parent = node.at_xpath("..")
      if(!parent || parent == node || parent.node_name == "dtbook")
        break
      end
      node = parent
      prevent_infinite_loop -= 1
      if(prevent_infinite_loop < 0)
        raise "XML file image was nested more than 100 levels deep"
      end
    end
    return nil
  end
  
  def create_prodnote_id(image_id)
    "pnid_#{image_id}"
  end
  
  def caller_info
    return "#{request.remote_addr}"
  end
  
  def create_zip(old_daisy_zip, contents_filename, new_xml_contents)
    new_daisy_zip = Tempfile.new('baked-daisy')
    new_daisy_zip.close
    FileUtils.cp(old_daisy_zip, new_daisy_zip.path)
    Zip::Archive.open(new_daisy_zip.path) do |zipfile|
      zipfile.num_files.times do |index|
        if(zipfile.get_name(index) == contents_filename)
          zipfile.replace_buffer(index, new_xml_contents)
          break
        end
      end
    end
    return new_daisy_zip.path
  end



end
