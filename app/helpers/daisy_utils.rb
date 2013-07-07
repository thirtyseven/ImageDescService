module DaisyUtils
  def valid_daisy_zip?(file)
    DaisyUtils.valid_daisy_zip?(file)
  end
  
  #valid epub
  #look for opf EpubUtils
  
  def self.valid_daisy_zip?(file)
    begin
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.name =~ /\.ncx$/
            return true
          end
        end
      end
    rescue Zip::Error => e
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        if e.message.include?("Not a zip archive")
            ActiveRecord::Base.logger.info "#{caller_info} Not a ZIP File"
            flash[:alert] = "Uploaded file must be a valid Daisy or EPub3 (zip) file"
        else
            ActiveRecord::Base.logger.info "#{caller_info} Other problem with zip"
          flash[:alert] = "There is a problem with this zip file"
        end
        puts e
        puts e.backtrace.join("\n")
        return false
    end
    flash[:alert] = "Uploaded file must be a valid Daisy or EPUB3 (zip) file"
    return false
  end
  
  def self.extract_book_uid(doc)
    xpath_uid = "//xmlns:meta[@name='dtb:uid']"
    matches = doc.xpath(doc, xpath_uid)
    if matches.size != 1
      raise MissingBookUIDException.new
    end
    node = matches.first
    return node.attributes['content'].content
  end

  def extract_book_title(doc)
    xpath_title = "//xmlns:meta[@name='dc:Title']"
    matches = doc.xpath(doc, xpath_title)
    if matches.size != 1
      return ""
    end
    node = matches.first
    return node.attributes['content'].content
  end

  def caller_info
    return "#{request.remote_addr}"
  end

  def get_daisy_contents_xml_name(book_directory) 
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end
  
end