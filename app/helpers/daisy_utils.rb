module DaisyUtils

  EXPECTED_DTD_FILES = ['dtbook-2005-2.dtd', 'dtbook-2005-3.dtd']

  def valid_daisy_zip?(file)
    DaisyUtils.valid_daisy_zip?(file)
  end
  
  def self.valid_daisy_zip?(file)
      Zip::Archive.open(file) do |zipfile|
        zipfile.each do |entry|
          if EXPECTED_DTD_FILES.include? entry.name
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
    return node.attributes['content'].content.gsub(/[^a-zA-Z0-9\-\_]/, '-')
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

  def self.get_contents_xml_name(book_directory) 
    return Dir.glob(File.join(book_directory, '*.xml'))[0]
  end
  
  def extract_images_prod_notes_for_daisy doc
      images = doc.xpath("//xmlns:img")
      prodnotes = doc.xpath("//xmlns:imggroup//xmlns:prodnote")
      captions = doc.xpath("//xmlns:imggroup//xmlns:caption")

      @num_images = images.size()
      limit = 249
      @prodnotes_hash = Hash.new()
      prodnotes.each do |node|
        # MQ: Why are we even querying the DB for a matching DynamicImage?
        # And why doesn't it care about the book the image belongs to?
        dynamic_image = DynamicImage.where(:xml_id => node['imgref']).first
        if (dynamic_image)
          @prodnotes_hash[dynamic_image] = node.inner_text
        else
          @prodnotes_hash[node['imgref']] = node.inner_text
        end
        break if @prodnotes_hash.size > limit
      end
      @captions_hash = Hash.new()

      captions.each do |node|
        @captions_hash[node['imgref']] = node.inner_text
        break if @captions_hash.size > limit
      end

      @alt_text_hash = Hash.new()
      images.each do |node|
        alt_text =  node['alt']
        id = node['id']
        if alt_text.size > 1
          @alt_text_hash[id] = alt_text
        end
        break if @alt_text_hash.size > limit
      end
  end
  
end