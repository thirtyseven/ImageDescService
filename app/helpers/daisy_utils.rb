module DaisyUtils
  def valid_daisy_zip?(file)
    DaisyUtils.valid_daisy_zip?(file)
  end
  
  def self.valid_daisy_zip?(file)
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.name =~ /\.ncx$/
            return true
          end
        end
      end
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

  def self.extract_book_title(doc)
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