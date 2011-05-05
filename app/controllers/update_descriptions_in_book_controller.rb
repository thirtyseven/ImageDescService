require "nokogiri"

class UnrecognizedProdnoteException < Exception
  
end

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
    rescue UnrecognizedProdnoteException
      # TODO: Should log a note here
      redirect_to :back, :alert => "Unable to update descriptions because the uploaded book contained descriptions from other sources"
      return
    rescue Exception => e
      # TODO: Need to log the exception here
      #$stderr.puts e
      redirect_to :back, :alert => "Uploaded file must be a valid Daisy book XML content file"
      return
    end
    
    send_data xml, :type => 'application/xml; charset=utf-8', :filename => book.original_filename, :disposition => 'attachment' 
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

      image_id = image['id']

        prodnote = parent.at_xpath("./xmlns:prodnote")
      if(!prodnote)
        prodnote = Nokogiri::XML::Node.new "prodnote", doc 
        image.add_next_sibling prodnote
      elsif(prodnote['id'] != create_prodnote_id(image_id))
        raise UnrecognizedProdnoteException.new
      end
      
      dynamic_description = dynamic_image.dynamic_descriptions.last
      prodnote.content = dynamic_description.body
      prodnote['render'] = 'optional'
      prodnote['imgref'] = image_id
      prodnote['id'] = create_prodnote_id(image_id)
      prodnote['showin'] = 'blp'
    end
    
    return doc.to_xml
  end
  
  def create_prodnote_id(image_id)
    "pnid_#{image_id}"
  end
end

