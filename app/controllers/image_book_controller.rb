require 'fileutils'
require 'nokogiri'
require 'tempfile'
require 'xml/xslt'
include ActionView::Helpers::NumberHelper
include DaisyUtils, UnzipUtils, EpubUtils

class ImageBookController < ApplicationController
  before_filter :authenticate_user!
  ROOT_XPATH = "/xmlns:dtbook"

  def initialize
    super()
    @repository = RepositoryChooser.choose
  end

  def check_image_coverage
    file_type = nil
    book = params[:book]
    if !book
      flash[:alert] = "Must specify a book file to check"
      redirect_to :action => 'image_check'
      return
    end
    
    if valid_daisy_zip?(book.path)
      file_type = "Daisy"
    elsif valid_epub_zip?(book.path)
      file_type = "Epub"
    else
      flash[:alert] = "Not a valid DAISY or EPUB book"
      redirect_to :action => 'image_check'
      return
    end

    begin
      zip_directory, book_directory, daisy_file = accept_and_copy_book(book.path, file_type)
      display_image_coverage zip_directory, book_directory, file_type
    rescue Zip::Error => e
      logger.info "#{e.class}: #{e.message}"
      logger.info "#{caller_info} Other problem with zip"
      flash[:alert] = "There is a problem with this zip file"
      redirect_to :action => 'image_check'
      return
    end

  end
  
  def submit_to_get_descriptions
    book = params[:book]
    password = params[:password]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'process'
      return
    end
    
    # Store file in S3
    p "Ok here we are uploading to S3"
    repository = RepositoryChooser.choose
    random_uid = UUIDTools::UUID.random_create.to_s
    @repository.store_file(book.path, 'delayed', random_uid, nil) #store file in a directory
    @job = Job.new({:user_id => current_user.id, :enter_params => ({:random_uid => random_uid, :password => password, :book_name => book.original_filename, :content_type => book.content_type}).to_json})
    @job.save
    DaisyBookHelper::BatchHelper.delay.batch_add_descriptions_to_book(@job.id, current_library)
  end
  
  def display_image_coverage zip_directory, book_directory, file_type
    begin
      contents_filename = nil
      @host = @repository.get_host(request)
      xml_file = get_xml_from_dir(book_directory, file_type)
      
 
      begin
        doc = Nokogiri::XML xml_file
        root = doc.xpath(doc, ROOT_XPATH)
        # if root.size != 1
        #   raise NonDaisyXMLException.new
        # end
        @book_title = extract_book_title(doc, file_type)
        
        if file_type == "Epub"
          extract_images_prod_notes_for_epub doc 
        else
          extract_images_prod_notes_for_daisy doc
        end

      rescue NonDaisyXMLException => e
        logger.info "#{caller_info} Uploaded non-dtbook #{contents_filename}"
        raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
      end

    end
  end
 
  
  def extract_images_prod_notes_for_epub doc
     images = doc.css('img')
     @num_images = images.size()
     limit = 249
     @prodnotes_hash = Hash.new()
     
     images.each do |img_node| 
       unless (img_node['src']).blank?
         db_image = DynamicImage.where(:book_id => book.id, :image_location => img_node['src']).first
         if db_image
             @prodnotes_hash[dynamic_image] =  img_node['src']
         end
         image_srces << img_node['src']
       end
     end
      @alt_text_hash = Hash.new()
      @captions_hash = Hash.new()
    
  end
  
  def extract_images_prod_notes_for_daisy doc
      images = doc.xpath("//xmlns:img")
      prodnotes = doc.xpath("//xmlns:imggroup//xmlns:prodnote")
      captions = doc.xpath("//xmlns:imggroup//xmlns:caption")

      @num_images = images.size()
      limit = 249
      @prodnotes_hash = Hash.new()
      prodnotes.each do |node|
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

  
  def poll_daisy_with_descriptions
    job = Job.where(:id => params[:job_id], :user_id => current_user.id).first
    
    if job && job.state == 'complete'
      render :text => "Complete"
    elsif job && job.state == 'error'
      render :text => "Error"
    else
      render :text => "Not Complete"
    end
  end
  
  def download_daisy_with_descriptions
    job = Job.where(:id => params[:job_id], :user_id => current_user.id).first
    repository = RepositoryChooser.choose
    
    if job && job.state == 'complete'
      exit_params = job.json_exit_params
      random_uid = exit_params['random_uid']
      basename = exit_params['basename']
      random_uid_book_location = repository.read_file(random_uid, File.join( "", "tmp", "#{random_uid}.zip"))
      send_file random_uid_book_location, :type => 'application/zip; charset=utf-8', :filename => basename + '.zip', :disposition => 'attachment' 
    else
      render :text => "Not Complete"
    end
  end
  
end
