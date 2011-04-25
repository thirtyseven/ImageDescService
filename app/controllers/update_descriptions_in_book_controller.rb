require "rexml/document"

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
      redirect_to :back, :alert => "Uploaded file must be a valid Daisy book XML content file"
      return
    end
    
    render :text => xml
  end
  
private
  def get_contents_with_updated_descriptions(file)
    doc = REXML::Document.new file

    xpath_uid = "//meta[@name='dtb:uid']/@content"
    book_uid = REXML::XPath.first(doc, xpath_uid).to_s

    xpath_title = "//meta[@name='dc:Title']/@content"
    book_title = REXML::XPath.first(doc, xpath_title).to_s

    matching_images = DynamicImage.where("uid = ?", book_uid)
    matching_images.each do | dynamic_image |
      image_location = dynamic_image.image_location
      image = REXML::XPath.first( doc, "//img[@src='#{image_location}']")
      parent = REXML::XPath.first( doc, "//img[@src='#{image_location}']/..")
      is_parent_image_group = (parent.expanded_name == 'imggroup')
      if(is_parent_image_group)
        prodnote = REXML::XPath.first(parent, "prodnote")
        if(!prodnote)
          prodnote = create_prodnote image.attributes['id']
          parent.add_element prodnote
        end
      else
        image_group = REXML::Element.new "imggroup"
        image_group.add_element image

        parent.delete_element image
        parent.add_element image_group

        prodnote = create_prodnote image.attributes['id']
        image_group.add prodnote
      end

      prodnote.text = dynamic_image.dynamic_descriptions.first.body
    end
    
    return doc.to_s
  end
  
  def create_prodnote(image_id)
    prodnote = REXML::Element.new "prodnote"
    prodnote.attributes['render'] = 'optional'
    prodnote.attributes['imgref'] = image_id
    prodnote.attributes['id'] = "pnid_#{image_id}"
    prodnote.attributes['showin'] = 'blp'
    return prodnote
  end

end
