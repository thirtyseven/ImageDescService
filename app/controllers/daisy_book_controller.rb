require "nokogiri"
require 'zip/zipfilesystem'

class NonDaisyXMLException < Exception
end

class MissingBookUIDException < Exception
end

class DaisyBookController < ApplicationController
  
  def upload
  end

  def edit
    book = params[:book]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'upload'
      return
    end
    
    file = File.new( book.path )
    if !valid_daisy_zip?(file)
      flash[:alert] = "Uploaded file must be a valid Daisy (zip) file"
      redirect_to :action => 'upload'
      return
    end
    
    book_directory = unzip_to_temp(file)
    session[:daisy_directory] = book_directory
    
    contents_filename = get_daisy_contents_xml_name(book_directory)
    puts "Rendering #{contents_filename}"
    render :text => get_text_to_display(contents_filename)
  end

private
  def valid_daisy_zip?(file)
    begin
      Zip::ZipFile.open(file) do |zipfile|
        zipfile.get_entry 'dtbook-2005-3.dtd'
      end
    rescue
      return false
    end
    
    return true
  end
  
  def unzip_to_temp(zipped_file)
    dir = Dir.mktmpdir
    Zip::ZipFile.foreach(zipped_file) do | entry |
      entry.extract(File.join(dir, entry.name))
    end
    return dir
  end
  
  def get_daisy_contents_xml_name(book_directory)
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end
  
  def get_text_to_display(book_xml_file)
    contents = File.read(book_xml_file)
    doc = Nokogiri::XML contents
    
    root = doc.xpath(doc, "/xmlns:dtbook")
    if root.size != 1
      raise NonDaisyXMLException.new
    end

    xpath_uid = "//xmlns:meta[@name='dtb:uid']"
    matches = doc.xpath(doc, xpath_uid)
    if matches.size != 1
      raise MissingBookUIDException.new
    end
    node = matches.first
    book_uid = node.attributes['content'].content
    
    images = doc.xpath( doc, "//xmlns:img")
    return "Successfully uploaded book (uid=#{book_uid}) which has #{images.size} images"
  end
end
