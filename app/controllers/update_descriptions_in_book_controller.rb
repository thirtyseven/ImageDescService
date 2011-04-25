require "nokogiri"

class UpdateDescriptionsInBookController < ApplicationController
  def upload
    book = params[:book]
    if !book
      redirect_to :back, :alert => "Must specify a book file to process"
      return
    end
    
    file = File.new( book.path )
    begin
      xml = get_contents_with_updated_descriptions(file)
    rescue Exception => e
      $stderr.puts(e.message)
      $stderr.puts(e.backtrace)
      redirect_to :back, :alert => "Uploaded file must be a valid Daisy book XML content file"
      return
    end
    
    render :text => xml
  end
  
private
  def get_contents_with_updated_descriptions(file)
    doc = Nokogiri::XML file

    xpath_uid = "//xmlns:meta[@name='dtb:uid']"
    matches = doc.xpath(doc, xpath_uid)

    node = matches.first
    book_uid = node.attributes['content'].content

    matching_images = DynamicImage.where("uid = ?", book_uid)
    matching_images.each do | dynamic_image |
      image_location = dynamic_image.image_location
      image = doc.at_xpath( doc, "//xmlns:img[@src='#{image_location}']")
      parent = doc.at_xpath( doc, "//xmlns:img[@src='#{image_location}']/..")

      is_parent_image_group = parent.matches?('//xmlns:imggroup')
      if(!is_parent_image_group)
        image_group = Nokogiri::XML::Node.new "imggroup", doc
        image_group.parent = parent
        
        parent.children.delete(image)
        image.parent = image_group
        parent = image_group
      end

      prodnote = parent.at_xpath("./xmlns:prodnote")
      if(!prodnote)
        prodnote = Nokogiri::XML::Node.new "prodnote", doc 
        image.add_next_sibling prodnote
      end
      
      image_id = image.attributes['id']
      prodnote.content = dynamic_image.dynamic_descriptions.first.body
      prodnote.attributes['render'] = 'optional'
      prodnote.attributes['imgref'] = image_id
      prodnote.attributes['id'] = "pnid_#{image_id}"
      prodnote.attributes['showin'] = 'blp'
    end
    
    return doc.to_xml
  end
  
end
