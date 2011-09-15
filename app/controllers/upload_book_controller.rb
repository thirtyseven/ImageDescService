require 'fileutils'
require 'nokogiri'
require 'tempfile'

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

class UploadBookController < ApplicationController
  ROOT_XPATH = "/xmlns:dtbook"

  def submit

    #init session vars
    session[:book_uid] = nil
    session[:content] = nil
    session[:daisy_directory] = nil

    book = params[:book]
    password = params[:password]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'upload'
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
      redirect_to :action => 'upload'
      return
    end

    begin
      accept_book(book.path)
      xml = get_xml_from_dir
      doc = Nokogiri::XML xml
      @book_uid = extract_book_uid(doc)

      pid = fork do
        # get handle to s3 service
        s3_service = AWS::S3.new
        # get an s3 bucket
        bucket = s3_service.buckets[ENV['POET_HOLDING_BUCKET']]

        s3_object = bucket.objects[@book_uid + ".zip"]
        begin
          if (! s3_object.exists?)
            if(File.exists?(book.path))
              s3_object.write(:file => book.path)
            else
              logger.warn("file does not exist in local dir #{book.path}")
              s3_object = nil
            end
          else
            #puts ("#{image_location} already exists")
          end
        rescue AWS::Errors::Base => e
          logger.info "S3 credentials incorrect"
        end
        s3_object = nil
        s3_service = nil
      end
      Process.detach(pid)

      render 'display_uid'

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

  def get_xml_from_dir
    book_directory = session[:daisy_directory]
    contents_filename = get_daisy_contents_xml_name(book_directory)
    File.read(contents_filename)
  end

  def get_daisy_contents_xml_name(book_directory)
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end


end