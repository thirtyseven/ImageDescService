class ApiController < ApplicationController

  STATUS_NOT_APPROVED = 203
  STATUS_NOT_FOUND = 203
  STATUS_APPROVED = 200

  def get_approved_descriptions_and_book_stats
    book_stats_from_uid(params[:book_uid]) do |book|
      images_and_descriptions = extract_image_and_description book
      stats = strip_attributes(book.book_stats_plus_unessential_images_described.all)
      {:stats => stats, :images_and_descriptions => images_and_descriptions}
    end
  end

  def get_approved_descriptions
    book_stats_from_uid(params[:book_uid]) do |book|
      images_and_descriptions = extract_image_and_description book
      {:images_and_descriptions => images_and_descriptions}
    end
  end

  def get_approved_book_stats
    book_stats_from_uid(params[:book_uid]) do |book|
      stats = strip_attributes(book.book_stats_plus_unessential_images_described.all)
      {:stats => stats}
    end
  end

  def get_approved_stats
    @stats = BookStats.connection.select_all("select b.uid, b.title, b.isbn, bs.total_images, bs.total_essential_images,
      bs.total_images_described, bs.approved_descriptions, b.last_approved from book_stats bs left join books b on bs.book_id = b.id
      where b.last_approved > '#{params[:since]}' and bs.approved_descriptions > 0")
    respond_to do |format|
      format.xml  { render :xml => @stats }
      format.json  { render :json => @stats, :callback => params[:callback] }
    end
  end
  
  protected
  def extract_image_and_description book
    book.current_images_and_descriptions.all.map do |image| 
      {:image => (image ? image.image_location : nil), :description => image.dynamic_descriptions.first}
    end
  end
  
  # to_xml has problems if a nil generated field is added to the select; for example Book#book_stats_plus_unessential_images_described has total_images_described - essential_images_described as unessential_images_described.  If you extract the attributes object things are happier
  def strip_attributes models
    models.map{|model| model.attributes}
  end
  # Load up a book based on a UID.  If found, call a block to process it and return the results in XML or JSON
  API_BOOK_ATTRIBUTE_NAMES = ['uid', 'title', 'isbn', 'last_approved']
  def book_stats_from_uid book_uid
    @status = STATUS_APPROVED
    @book = Book.where(:uid => book_uid).first

    if @book && @book.last_approved
      @results = yield @book
    else
      if @book
        @results = {:error_message => "error: not approved"}
        @status = STATUS_NOT_APPROVED
      else
        @results = {:error_message => "error: book not found"}
        @status = STATUS_NOT_FOUND
      end
    end
    
    book_attributes = if @book
      API_BOOK_ATTRIBUTE_NAMES.inject({}){|acc, name| acc[name] = @book.attributes[name]; acc}
    end || {}
    respond_to do |format|
      @results ||= {}
      format.xml  do
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root {
            xml.book {render_xml_attributes xml, book_attributes}
            xml.status @status
            if @results
              @results.each do |k, v|
                k = k.to_s.dasherize
                if v.is_a?(Array)
                  if k == 'images-and-descriptions'
                    v.each do |image_desc|
                      xml.send k do
                        xml.image image_desc[:image]
                        xml.description { xml.cdata image_desc[:description] ? image_desc[:description].body : '' }
                      end
                    end
                  elsif v.is_a? Array
                    v.each do |sub_v| 
                      xml.send k do
                        render_xml_attributes xml, sub_v
                      end
                    end
                  else
                    xml.send k do
                      render_xml_attributes xml, v
                    end
                  end
                else
                  xml.send k, v
                end
              end
            end
          }
        end
        render :text => builder.to_xml, :status => @status
      end
      format.json  { render :json => {:book => book_attributes, :callback => params[:callback], :status => @status}.merge(@results), :status => @status }
    end
  end
  
  def render_xml_attributes xml, attributes
    attributes.each {|k, v| p xml.send(k.to_s.dasherize, v) if k}
  end
end