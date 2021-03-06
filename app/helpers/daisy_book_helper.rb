module DaisyBookHelper
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
      zip_directory, book_directory, daisy_file = UnzipUtils.accept_and_copy_book(random_uid_book_location, "Daisy")
      book = File.open daisy_file
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

      if !DaisyUtils.valid_daisy_zip?(book.path)
        flash[:alert] = "Not a valid DAISY book"
        redirect_to :action => 'process'
        return
      end
      
      begin
        get_daisy_with_descriptions zip_directory, book_directory, daisy_file, job, current_library
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
    
  
    def self.get_daisy_with_descriptions zip_directory, book_directory, daisy_file, job, current_library
      begin
        contents_filename = DaisyUtils.get_contents_xml_name(book_directory)
        relative_contents_path = contents_filename[zip_directory.length..-1]
        if(relative_contents_path[0,1] == '/')
          relative_contents_path = relative_contents_path[1..-1]
        end
        xml = get_xml_contents_with_updated_descriptions(contents_filename, current_library)
        zip_filename = create_zip(daisy_file, relative_contents_path, xml)
        basename = File.basename(contents_filename)
        ActiveRecord::Base.logger.info "Sending zip #{zip_filename} of length #{File.size(zip_filename)}"
      
        # Store this file in S3, update the Job; change exit_params and the state
        random_uid = UUIDTools::UUID.random_create.to_s
        repository = RepositoryChooser.choose
        repository.store_file(zip_filename, 'delayed', random_uid, nil) #store file in a directory
        job.update_attributes :state => 'complete', :exit_params => ({:basename => basename, :random_uid => random_uid}).to_json
      rescue ShowAlertAndGoBack => e
        flash[:alert] = e.message
        job.update_attributes :state => 'error', :error_explanation => 'Unable to process this book at this time.  Please contact your Poet administrator.'
        redirect_to :action => 'process'
        return
      end
    end

    
    def self.get_xml_contents_with_updated_descriptions(contents_filename, current_library)
      xml_file = File.read(contents_filename)
      begin
        xml = get_contents_with_updated_descriptions(xml_file, current_library)
      rescue NoImageDescriptions
        ActiveRecord::Base.logger.info "No descriptions available #{contents_filename}"
        raise ShowAlertAndGoBack.new("There are no image descriptions available for this book")
      rescue NonDaisyXMLException => e
        ActiveRecord::Base.logger.info "Uploaded non-dtbook #{contents_filename}"
        raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
      rescue MissingBookUIDException => e
        ActiveRecord::Base.logger.info "Uploaded dtbook without UID #{contents_filename}"
        raise ShowAlertAndGoBack.new("Uploaded Daisy book XML content file must have a UID element")
      rescue Nokogiri::XML::XPath::SyntaxError => e
        ActiveRecord::Base.logger.info "Uploaded invalid XML file #{contents_filename}"
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        ActiveRecord::Base.logger.info "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        raise ShowAlertAndGoBack.new("Uploaded file must be a valid Daisy book XML content file")
      rescue Exception => e
        ActiveRecord::Base.logger.info "Unexpected exception processing #{contents_filename}:"
        ActiveRecord::Base.logger.info "#{e.class}: #{e.message}"
        ActiveRecord::Base.logger.info e.backtrace.join("\n")
        $stderr.puts e
        raise ShowAlertAndGoBack.new("An unexpected error has prevented processing that file")
      end

      return xml
    end
    
    def self.create_zip(old_daisy_zip, contents_filename, new_xml_contents)
      new_daisy_zip = Tempfile.new('baked-daisy')
      new_daisy_zip.close
      FileUtils.cp(old_daisy_zip, new_daisy_zip.path)
      Zip::Archive.open(new_daisy_zip.path) do |zipfile|
        zipfile.num_files.times do |index|
          if(zipfile.get_name(index) == contents_filename)
            zipfile.replace_buffer(index, new_xml_contents)
            break
          end
        end
      end
      return new_daisy_zip.path
    end
    
    def get_description_count_for_book_uid(book_uid, current_library)
      DaisyBookHelper::BatchHelper.get_description_count_for_book_uid(book_uid, current_library)
    end
    def self.get_description_count_for_book_uid(book_uid, current_library)
      return DynamicImage.
          joins(:book).
          where(:books => {:uid => book_uid, :library_id => current_library.id}).
          count
    end
    
    def get_contents_with_updated_descriptions(file, current_library)
      DaisyBookHelper::BatchHelper.get_contents_with_updated_descriptions(file, current_library)
    end
    def self.get_contents_with_updated_descriptions(file, current_library)
      doc = Nokogiri::XML file

      root = doc.xpath(doc, ROOT_XPATH)
      if root.size != 1
        raise NonDaisyXMLException.new
      end

      book_uid = DaisyUtils.extract_book_uid(doc)

      if get_description_count_for_book_uid(book_uid, current_library) == 0
        raise NoImageDescriptions.new
      end

      book = Book.where(:uid => book_uid, :library_id => current_library.id, :deleted_at => nil).first
      matching_images = DynamicImage.where("book_id = ?", book.id).all
      matching_images.each do | dynamic_image |
        image_location = dynamic_image.image_location

        image_references = doc.xpath("//xmlns:img[@src='#{image_location}']")
        if image_references.size == 0
          ActiveRecord::Base.logger.info "Missing img element for database description #{book_uid} #{image_location}"
          next
        end

        dynamic_description = dynamic_image.dynamic_description
        if(!dynamic_description)
          ActiveRecord::Base.logger.info "Image #{book_uid} #{image_location} is in database but with no descriptions"
          next
        end

        image_references.each do |image|

          # note that there's no guarantee this will be non-null
          image_id = image['id']

          # Attempt to find the parent imggroup
          parent = image.at_xpath("..")
          imggroup = get_imggroup_parent_of(image)

          # Push down into an imggroup element if none already exists
          if(!imggroup)
            imggroup = Nokogiri::XML::Node.new "imggroup", doc
            # could result in an ID collision
            imggroup['id'] =  "imggroup_#{image_id}"
            imggroup.parent = parent

            parent.children.delete(image)
            image.parent = imggroup
            parent = imggroup
          end

          # Attempt to locate prodnote that conforms to our ID naming convention 
          prodnotes = imggroup.xpath(".//xmlns:prodnote")
          our_prodnote = nil
          prodnotes.each do | prodnote |

            if(prodnote['id'] == create_prodnote_id(image_id))
              # Found a match, keep it
              our_prodnote = prodnote
            end
          end

          # If not found, create a new one
          if(!our_prodnote)
            our_prodnote = Nokogiri::XML::Node.new "prodnote", doc 
            imggroup.add_child our_prodnote 
          end

          # flush old contents then append most recent ones
          our_prodnote.children.each do |child|
            child.remove
          end

          our_prodnote.add_child(dynamic_description.body)
          our_prodnote['render'] = 'optional'
          our_prodnote['imgref'] = image_id
          our_prodnote['id'] = create_prodnote_id(image_id)
          our_prodnote['showin'] = 'blp'
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
