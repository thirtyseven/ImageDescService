module EpubUtils
  def valid_epub_zip?(file)
    EpubUtils.valid_epub_zip?(file)
  end
  
  #valid epub
  #look for opf EpubUtils
  def self.valid_epub_zip?(file)
    begin
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.name =~ /package\.opf$/
            return true
          end
        end
      end
    rescue Zip::Error => e
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        if e.message.include?("Not a zip archive")
            ActiveRecord::Base.logger.info "#{caller_info} Not a ZIP File"
       #     flash[:alert] = "Uploaded file must be a valid Epub (zip) file"
        else
            ActiveRecord::Base.logger.info "#{caller_info} Other problem with zip"
        #    flash[:alert] = "There is a problem with this zip file"
        end
        puts e
        puts e.backtrace.join("\n")
        return false
    end
   flash[:alert] = "Uploaded file must be a valid EPUB3 file"
    return false
  end
  
  def get_epub_file_main_directory(book_directory)
      opf_file = "**/package.opf" 
      opf_dir = Dir.glob("#{book_directory}/#{opf_file}").first
      File.dirname opf_dir
  end
  
  def get_epub_contents_xml_name(book_directory)
      book_dir = get_epub_file_main_directory book_directory 
      return Dir.glob(File.join(book_dir, 'package.opf'))[0]
  end
   
 def get_epub_book_xml_file_names(book_directory)   
     book_dir = get_epub_file_main_directory book_directory 
     return Dir.glob(File.join(book_dir, '*.xhtml'))
 end
   
  def self.extract_book_uid(doc)
    xpath_uid = doc.css("[id='pub-id']").first.text if doc.css("[id='pub-id']").first
    if !xpath_uid
      raise MissingBookUIDException.new
    end
    return xpath_uid
  end
  

  
  # 
  #  def extract_book_title(doc)
  #    xpath_title = "//xmlns:meta[@name='dc:Title']"
  #    matches = doc.xpath(doc, xpath_title)
  #    if matches.size != 1
  #      return ""
  #    end
  #    node = matches.first
  #    return node.attributes['content'].content
  #  end
  # 
  #  def caller_info
  #    return "#{request.remote_addr}"
  #  end

end