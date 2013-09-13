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
  
  def self.get_contents_xml_name(book_directory)
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
  
  def extract_images_prod_notes_for_epub doc, book_directory
     @prodnotes_hash = Hash.new()
     @alt_text_hash = Hash.new()
     @captions_hash = Hash.new()
     limit = 249
     book_uid = EpubUtils.extract_book_uid doc
     book = Book.where(:uid => book_uid).first
  
     file_names = get_epub_book_xml_file_names(book_directory)
     file_contents = file_names.inject('') do |acc, file_name|
      cur_file_contents = File.read(file_name)
      cur_doc = Nokogiri::XML cur_file_contents
      acc = "#{acc} #{cur_doc.css('body').children.to_s}"
      acc
     end

     file_contents = "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'><link rel='stylesheet' type='text/css' href='//s3.amazonaws.com/org-benetech-poet/html.css'/><body>#{file_contents}</body></html>"
     doc = Nokogiri::XML file_contents
     doc.css('img').each do |img_node| 
       unless (img_node['src']).blank? 
         image_name =  img_node['src'].gsub!(/images\//i, '') 
         alt_text =  img_node['alt']
         if alt_text.size > 1
           @alt_text_hash[image_name] = alt_text
         end
         break if @alt_text_hash.size > limit
       end
     end
  end
 
  #  def caller_info
  #    return "#{request.remote_addr}"
  #  end

end