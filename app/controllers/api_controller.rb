class ApiController < ApplicationController

  STATUS_NOT_APPROVED = 203
  STATUS_NOT_FOUND = 203
  STATUS_APPROVED = 200

  def get_image_approved
    image_id = params[:dynamic_image_id]
    image = DynamicImage.where(:id => image_id).first
    image_desc = DynamicDescription.where(:dynamic_image_id => image.id).where('date_approved is not null').order(:date_approved).first if image
    
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.send 'd:description', {'xml:id'=>image_desc.id, 'xml:lang'=>"en",
              'xmlns'=>"http://www.daisy.org/ns/z3998/authoring/",
              'xmlns:d'=>"http://www.daisy.org/ns/z3998/authoring/features/description/",
              'xmlns:xlink'=>"http://www.w3.org/1999/xlink"} do
            if image_desc
              target_age = "#{image_desc.target_age_start}-#{image_desc.target_age_end}" if image_desc.target_age_start.present? || image_desc.target_age_end.present?      
              target_grade = "#{image_desc.target_grade_start}-#{image_desc.target_grade_end}" if image_desc.target_grade_start.present? || image_desc.target_grade_end.present?      
            
              # missing fields currentVersion,  tactile,  tour (tactile), tour (SimplifiedImage)
              xml.send 'd:head' do
                xml.meta(:property => "dc:identifier", :content => image_desc.id) 
                xml.meta(:property => "dc:language", :content => image_desc.language)
                xml.meta(:property => "diagram:targetAge", :content => target_age)
                xml.meta(:property => "diagram:targetGrade", :content => target_grade)
                xml.meta(:property => "diagram:descriptionQuality", :content => image_desc.description_quality)                                                        
                xml.meta(:rel=>"diagram:currentVersion", :resource=>"TODO")
                xml.meta(image_desc.submitter, :property => "dc:creator", :id => 'author01')   
                xml.meta(image_desc.repository, :rel => "diagram:repository")
              end
              xml.send 'd:body' do
                xml.send 'd:summary', :id => 'summary' do
                  xml.cdata image_desc.summary ? image_desc.summary : ''
                end
                xml.send 'd:longdesc', :id => 'longdesc01' do
                  xml.cdata image_desc.body ? image_desc.body : ''
                end
                xml.annotation(image_desc.annotation, :ref => 'longdesc01', :role => 'diagram:comment', :by => 'teacher') 
                xml.send 'd:simplifiedLanguageDescription', :id => 'simpledesc01' do
                  xml.cdata image_desc.simplified_language_description ? image_desc.simplified_language_description : ''
                end
                xml.send "d:tactile", {'xml:id'=>"tactile01"} do
                  xml.cdata 'TODO'
                end
              end
            end
          end
        end
        builder.doc.root.add_previous_sibling Nokogiri::XML::ProcessingInstruction.new(builder.doc, "xml-stylesheet", 'type="text/xsl" href="desc2html.xsl"')
        
        render :text => builder.to_xml
        
  end

  def get_image_descriptions
    book_stats_from_uid(params[:book_uid]) do |book|
      dynamic_descriptions = extract_dynamic_description_images book
      {:dynamic_descriptions => dynamic_descriptions}
    end
  end
  
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

  def extract_dynamic_description_images book
    book.current_images_and_descriptions.all.map do |image|
      {:image => (image ? image.image_location : nil), :longdesc => image.dynamic_descriptions.first.body, :iscurrent => image.dynamic_descriptions.first.is_current,
        :submitter => image.dynamic_descriptions.first.submitter, :date_approved => image.dynamic_descriptions.first.date_approved, :dynamic_image_id => image.dynamic_descriptions.first.dynamic_image_id,
        :book_id => image.dynamic_descriptions.first.book_id, :book_fragment_id => image.dynamic_descriptions.first.book_fragment_id, :summary => image.dynamic_descriptions.first.summary, 
        :simplified_language_description => image.dynamic_descriptions.first.simplified_language_description, :target_age_start => image.dynamic_descriptions.first.target_age_start, :target_age_end => image.dynamic_descriptions.first.target_age_end, 
        :target_grade_start => image.dynamic_descriptions.first.target_grade_start, :target_grade_end => image.dynamic_descriptions.first.target_grade_end, :description_quality => image.dynamic_descriptions.first.description_quality, 
        :language => image.dynamic_descriptions.first.language, :repository => image.dynamic_descriptions.first.repository, :credentials => image.dynamic_descriptions.first.credentials, :annotation => image.dynamic_descriptions.first.annotation}
    end  
  end
  
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
                    xml.send k do
                      v.each do |image_desc|
                        xml.send 'images-and-description' do
                          xml.image image_desc[:image]
                          xml.description { xml.cdata image_desc[:description] ? image_desc[:description].body : '' }
                        end
                      end
                    end
                  elsif k == "dynamic-descriptions"
                   xml.send k do
                      v.each do |image_desc| 
                        xml.send 'dynamic-description' do
                          xml.image image_desc[:image]
                          xml.longdesc { xml.cdata image_desc[:longdesc] ? image_desc[:longdesc] : '' }
                          xml.iscurrent image_desc[:iscurrent]
                          xml.submitter image_desc[:submitter]
                          xml.date_approved image_desc[:date_approved]
                          xml.dynamic_image_id image_desc[:dynamic_image_id]
                          xml.book_id image_desc[:book_id]
                          xml.book_fragment_id image_desc[:book_fragment_id]  
                          xml.summary { xml.cdata image_desc[:summary] ? image_desc[:summary] : '' }
                          xml.simplified_language_description { xml.cdata image_desc[:simplified_language_description].present? ? image_desc[:simplified_language_description] : '' }
                          xml.target_age_start image_desc[:target_age_start]
                          xml.target_age_end image_desc[:target_age_end]
                          xml.target_grade_start image_desc[:target_grade_start]
                          xml.target_grade_end image_desc[:target_grade_end]
                          xml.description_quality image_desc[:description_quality]
                          xml.language image_desc[:language]
                          xml.repository image_desc[:repository]
                          xml.credentials image_desc[:credentials]   
                          xml.annotation image_desc[:annotation]  
                        end
                      end
                    end
                  elsif v.is_a? Array
                    xml.send k do
                      v.each do |sub_v| 
                        xml.send k.to_s.singularize do
                          render_xml_attributes xml, sub_v
                        end
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