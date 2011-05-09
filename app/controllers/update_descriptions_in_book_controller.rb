require "nokogiri"

class UnrecognizedProdnoteException < Exception
end

class NonDaisyXMLException < Exception
end

class MissingBookUIDException < Exception
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
      logger.info "#{caller_info} Unrecognized prodnote elements in #{book.original_filename}"
      redirect_to :back, :alert => "Unable to update descriptions because the uploaded book contained descriptions from other sources"
      return
    rescue NonDaisyXMLException => e
      logger.info "#{caller_info} Uploaded non-dtbook #{book.original_filename}"
      redirect_to :back, :alert => "Uploaded file must be a valid Daisy book XML content file"
      return
    rescue MissingBookUIDException => e
      logger.info "#{caller_info} Uploaded dtbook without UID #{book.original_filename}"
      redirect_to :back, :alert => "Uploaded Daisy book XML content file must have a UID element"
      return
    rescue Nokogiri::XML::XPath::SyntaxError => e
      logger.info "#{caller_info} Uploaded invalid XML file #{book.original_filename}"
      logger.info "#{e.class}: #{e.message}"
      logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
      redirect_to :back, :alert => "Uploaded file must be a valid Daisy book XML content file"
      return
    rescue Exception => e
      logger.info "#{caller_info} Unexpected exception processing #{book.original_filename}:"
      logger.info "#{e.class}: #{e.message}"
      logger.info e.backtrace.join("\n")
      redirect_to :back, :alert => "An unexpected error has prevented processing that file"
      return
    end
    
    send_data xml, :type => 'application/xml; charset=utf-8', :filename => book.original_filename, :disposition => 'attachment' 
  end
  
private
  def get_contents_with_updated_descriptions(file)
    doc = Nokogiri::XML file
    
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

    matching_images = DynamicImage.where("uid = ?", book_uid)
    matching_images.each do | dynamic_image |
      image_location = dynamic_image.image_location
      image = doc.at_xpath( doc, "//xmlns:img[@src='#{image_location}']")
      parent = doc.at_xpath( doc, "//xmlns:img[@src='#{image_location}']/..")

      if !parent
        logger.info "Missing img element for database description #{book_uid} #{image_location}"
        next
      end
      
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
      
      dynamic_description = dynamic_image.best_description
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
  
  def caller_info
    return "#{request.remote_addr}"
  end
end

