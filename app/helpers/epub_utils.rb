module EpubUtils
  def valid_epub_zip?(file)
    EpubUtils.valid_epub_zip?(file)
  end
  

  def self.valid_epub_zip?(file)
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.name =~ /package\.opf$/
            return true
          end
        end
      end
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
  
  def self.extract_book_title(doc)
    doc.css("[property='dcterms:title']").first.text if doc.css("[property='dcterms:title']").first
  end
  

  #  def caller_info
  #    return "#{request.remote_addr}"
  #  end

end