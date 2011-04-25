require "rexml/document"

class UpdateDescriptionsInBookController < ApplicationController
  def upload
    result = []
    
    book = params[:book]
    if !book
      redirect_to :back, :alert => "Must specify a book file to process"
      return
    end
    
    file = File.new( book.path )
    doc = REXML::Document.new file
    
    xpath_uid = "//meta[@name='dtb:uid']/@content"
    book_uid = REXML::XPath.first(doc, xpath_uid).to_s
    result << "Book uid: #{book_uid}<br/>"

    xpath_title = "//meta[@name='dc:Title']/@content"
    book_title = REXML::XPath.first(doc, xpath_title).to_s
    result << "Book Title: #{book_title}<br/>"

    matching_images = DynamicImage.where("uid = ?", book_uid)
    matching_images.each do | dynamic_image |
      image_location = dynamic_image.image_location
      element = REXML::XPath.first( doc, "//img[@src='#{image_location}']")
      result << "#{element.attributes['id']} #{image_location}<br/>"
      dynamic_image.dynamic_descriptions.each do | description |
        result << "&nbsp;&nbsp;#{description.updated_at} #{description.body} <br/>"
      end
    end

    render :text => result.join("\n")
  end
end
