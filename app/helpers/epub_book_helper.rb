module EpubBookHelper
  class BatchHelper
    ROOT_XPATH = "/xmlns:dtbook"

    def self.batch_add_descriptions_to_book job_id, current_library
      job = Job.where(:id => job_id).first
      # Retrieve file from S3
      repository = RepositoryChooser.choose
      enter_params = job.json_enter_params
      password = enter_params['password']
      random_uid = enter_params['random_uid']
      random_uid_book_location = repository.read_file(random_uid, File.join( "", "tmp", "#{random_uid}.zip"))
      zip_directory, book_directory, epub_file = UnzipUtils.accept_and_copy_book(random_uid_book_location, "Epub")
      book = File.open epub_file
      unless password.blank?
        begin
          Zip::Archive.decrypt(book.path, password)
        rescue Zip::Error => e
          ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
          if e.message.include?("Wrong password")
            ActiveRecord::Base.logger.info "Invalid Password for encyrpted zip"
            flash[:alert] = "Please check your password and re-enter"
          else
            ActiveRecord::Base.logger.info "Other problem with encrypted zip"
            flash[:alert] = "There is a problem with this zip file"
          end
          redirect_to :action => 'process'
          return
        end
      end

      if !EpubUtils.valid_epub_zip?(book.path)
        flash[:alert] = "Not a valid Epub book"
        redirect_to :action => 'process'
        return
      end
      
      begin
        get_epub_with_descriptions zip_directory, book_directory, epub_file, job, current_library
      rescue Zip::Error => e
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        if e.message.include?("File encrypted")
          ActiveRecord::Base.logger.info "Password needed for zip"
          flash[:alert] = "Please enter a password for this book"
        else
          ActiveRecord::Base.logger.info "Other problem with zip"
          flash[:alert] = "There is a problem with this zip file"
        end

        redirect_to :action => 'process'
        return
      end
    end
    
  
    def self.get_epub_with_descriptions zip_directory, book_directory, epub_file, job, current_library
      begin
        contents_filenames = EpubUtils.get_epub_book_xml_file_names(book_directory)
        relative_contents_path = contents_filenames[0][zip_directory.length..-1]
       
        if(relative_contents_path[0,1] == '/')
          relative_contents_path = relative_contents_path[1..-1]
        end
        
        xml = get_xml_contents_with_updated_descriptions(book_directory, contents_filenames, current_library)
        zip_filename = create_zip(epub_file, relative_contents_path, xml)
        basename = File.basename(contents_filenames[0])
        ActiveRecord::Base.logger.info "Sending zip #{zip_filename} of length #{File.size(zip_filename)}"
      
        # Store this file in S3, update the Job; change exit_params and the state
        random_uid = UUIDTools::UUID.random_create.to_s
        repository = RepositoryChooser.choose
        repository.store_file(zip_filename, 'delayed', random_uid, nil) #store file in a directory
        job.update_attributes :state => 'complete', :exit_params => ({:basename => basename, :random_uid => random_uid}).to_json
      rescue ShowAlertAndGoBack => e
       # flash[:alert] = e.message
        job.update_attributes :state => 'error', :error_explanation => 'Unable to process this book at this time.  Please contact your Poet administrator.'
        redirect_to :action => 'process'
        return
      end
    end
    
    
    def self.get_xml_contents_with_updated_descriptions(book_directory, contents_filenames, current_library)
      begin
        xml = EpubBookHelper::BatchHelper.get_contents_with_updated_descriptions(book_directory, contents_filenames, current_library)
      rescue NoImageDescriptions
        ActiveRecord::Base.logger.info "No descriptions available #{contents_filenames}"
        raise ShowAlertAndGoBack.new("There are no image descriptions available for this book")
      rescue MissingBookUIDException => e
        ActiveRecord::Base.logger.info "Uploaded EPUB without Publication ID #{contents_filenames}"
        raise ShowAlertAndGoBack.new("Uploaded EPUB XML content file must have a Publication ID element")
      rescue Nokogiri::XML::XPath::SyntaxError => e
        ActiveRecord::Base.logger.info "Uploaded file must contain a valid EPUB Content Document #{contents_filenames}"
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        ActiveRecord::Base.logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        raise ShowAlertAndGoBack.new("Uploaded file must contain a valid EPUB Content Document")
      rescue Exception => e
        ActiveRecord::Base.logger.info "Unexpected exception processing #{contents_filenames}:"
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        ActiveRecord::Base.logger.info e.backtrace.join("\n")
        $stderr.puts e
        raise ShowAlertAndGoBack.new("An unexpected error has prevented processing that file")
      end

      return xml
    end
    
    def self.create_zip(old_file_zip, contents_filename, new_xml_contents)
      new_file_zip = Tempfile.new('baked-book')
      new_file_zip.close
      FileUtils.cp(old_file_zip, new_file_zip.path)
      Zip::Archive.open(new_file_zip.path) do |zipfile|
        zipfile.num_files.times do |index|
          if(zipfile.get_name(index) == contents_filename)
            zipfile.replace_buffer(index, new_xml_contents)
            break
          end
        end
      end
      return new_file_zip.path
    end
    
    def get_description_count_for_book_uid(book_uid, current_library)
      DaisyBookHelper::BatchHelper.get_description_count_for_book_uid(book_uid, current_library)
    end
    def self.get_description_count_for_book_uid(book_uid, current_library)
      return DynamicImage.
          joins(:book).
          where(:books => {:uid => book_uid, :library_id => current_library.id, :deleted_at => nil}).
          count
    end
    
    def self.get_contents_with_updated_descriptions(book_directory, contents_filenames, current_library)
      xml =  File.read(EpubUtils.get_contents_xml_name(book_directory)) 
      doc = Nokogiri::XML xml
      book_uid = EpubUtils.extract_book_uid(doc)
      @book_uid = book_uid
      
      xml_file = contents_filenames.inject('') do |acc, file_name|
        cur_file_contents = File.read(file_name)
        cur_doc = Nokogiri::XML cur_file_contents
        acc = "#{acc} #{cur_doc.css('body').children.to_s}"
        acc
      end
      xml_file = "<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'><link rel='stylesheet' type='text/css' href='//s3.amazonaws.com/org-benetech-poet/html.css'/><body>#{xml_file}</body></html>"

      if get_description_count_for_book_uid(book_uid, current_library) == 0
        raise NoImageDescriptions.new
      end

      book = Book.where(:uid => book_uid, :library_id => current_library.id, :deleted_at => nil).first
      matching_images = DynamicImage.where("book_id = ?", book.id).all
      matching_images_hash = Hash.new()
      matching_images.each do | dynamic_image |
         matching_images_hash[dynamic_image.image_location] = dynamic_image
       #  p "image location in dbis #{dynamic_image.image_location} "
      end
      
      
      doc = Nokogiri::XML xml_file
      doc.css('img').each do |img_node| 
         unless (img_node['src']).blank? 
           image_location =  img_node['src']
           matched_image = matching_images_hash[image_location]
           unless matched_image == nil 
             # this is a problem; what about images that are reused multiple times?
             # when the xml parser gets to that image node, the image description
             # is no longer in the hash. 
             matching_images_hash.delete(image_location) 
             dynamic_description = matched_image.dynamic_description
             if(!dynamic_description)
               ActiveRecord::Base.logger.info "Image #{book_uid} #{image_location} is in database but with no descriptions"
               
               next
             end
             parent_node = img_node.parent
             figure_node = Nokogiri::XML::Node.new "figure", doc 
             parent_node.children.delete(img_node)
             img_node['aria-describedby'] = dynamic_description.id.to_s 
             parent_node.add_child  figure_node
             figure_node.add_child img_node
             figcaption_node = Nokogiri::XML::Node.new "figcaption", doc
             figure_node.add_child figcaption_node
             details_node = Nokogiri::XML::Node.new "details", doc
             details_node['id'] = dynamic_description.id.to_s
             figcaption_node.add_child details_node
             summary_node = Nokogiri::XML::Node.new "summary", doc
             details_node.content = dynamic_description.body
             details_node.add_child summary_node
          end
         end   
       end
      return doc.to_xml
    end
    
    def create_prodnote_id(image_id)
      DaisyBookHelper::BatchHelper.create_prodnote_id(image_id)
    end
    def self.create_prodnote_id(image_id)
      "pnid_#{image_id}"
    end
    
    
    def get_imggroup_parent_of(image_node)
      DaisyBookHelper::BatchHelper.get_imggroup_parent_of(image_node)
    end
    def self.get_imggroup_parent_of(image_node)
      node = image_node
      prevent_infinite_loop = 100
      while(node)
        if(node.node_name == "imggroup")
          return node
        end
        parent = node.at_xpath("..")
        if(!parent || parent == node || parent.node_name == "dtbook")
          break
        end
        node = parent
        prevent_infinite_loop -= 1
        if(prevent_infinite_loop < 0)
          raise "XML file image was nested more than 100 levels deep"
        end
      end
      return nil
    end
    
  end
end
