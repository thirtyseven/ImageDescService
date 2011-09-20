class S3UnzippingJob < Struct.new(:book_uid)

  def enqueue(job)

  end

  def perform

    begin
        # get handle to s3 service
        s3_service = AWS::S3.new

        # get s3 bucket to download zip file
        holding_bucket = s3_service.buckets[ENV['POET_HOLDING_BUCKET']]
        s3_object_zip = holding_bucket.objects[book_uid + ".zip"]

        daisy_file = File.join( "", "tmp", "#{book_uid}.zip")
        File.open(daisy_file, 'wb') {|f| f.write(s3_object_zip.read) }
        book_directory = accept_book(daisy_file)

        xml = get_xml_from_dir(book_directory)
        doc = Nokogiri::XML xml
        contents_filename = get_daisy_contents_xml_name(book_directory)
        book = create_book_in_db(doc, File.basename(contents_filename))

        create_images_in_database(book_directory, doc)
        book.update_attribute("status", 2)
        upload_files_to_s3(book_directory, doc)
        book.update_attribute("status", 3)
        doc = nil
        xml = nil

        # remove zip file from holding bucket
        s3_object_zip.delete

        s3_service = nil
        holding_bucket = nil
        s3_object_zip = nil
        daisy_file = nil
      rescue AWS::S3::Errors::NoSuchKey => e
          puts "S3 Problem reading from S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
      rescue Exception => e
          puts "Unknown problem reading from S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
    end
  end

  def accept_book(book_path)
    zip_directory = unzip_to_temp(book_path)
    top_level_entries = Dir.entries(zip_directory)
    top_level_entries.delete('.')
    top_level_entries.delete('..')
    if(top_level_entries.size == 1)
      book_directory = File.join(zip_directory, top_level_entries.first)
    else
      book_directory = zip_directory
    end
  end

  def unzip_to_temp(zipped_file)
    dir = Dir.mktmpdir
    Zip::Archive.open(zipped_file) do |zipfile|
      zipfile.each do |entry|
        destination = File.join(dir, entry.name)
        if entry.directory?
          FileUtils.mkdir_p(destination)
        else
          dirname = File.join(dir, File.dirname(entry.name))
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
          open(destination, 'wb') do |f|
            f << entry.read
          end
        end
      end
    end
    return dir
  end

  def create_book_in_db(doc, xml_file)
    @book_title = extract_optional_book_title(doc)
    book = Book.find_by_uid(book_uid)
    if (!book)
      Book.create(
          :uid => book_uid,
          :title => @book_title,
          :status => 1,
          :xml_file => xml_file
      )
    end
  end

  def create_images_in_database(book_directory, doc)

    each_image(doc) do | image_node |
      image_location = image_node['src']
      xml_id = image_node['id']

      # if src exists
      if (image_location)

        # add image to db if it does not already exist in db
        image = DynamicImage.find_by_book_uid_and_image_location(book_uid, image_location)
        if(!image && File.exists?(File.join(book_directory, image_location)))
          width, height = get_image_size(book_directory, image_location)
          DynamicImage.create(
                :book_uid => book_uid,
                :book_title => @book_title,
                :width => width,
                :height => height,
                :xml_id => xml_id,
                :image_location => image_location)
        elsif (image)
          # may need to backfill existing rows without xml id
          if (! image.xml_id)
            image.update_attribute("xml_id", xml_id)
          end
        end
      end
    end
  end

  def upload_files_to_s3(book_directory, doc)
    # get handle to s3 service
    s3_service = AWS::S3.new
    # get an s3 bucket
    bucket = s3_service.buckets[ENV['POET_ASSET_BUCKET']]

    contents_filename = get_daisy_contents_xml_name(book_directory)

    content = File.basename(contents_filename)

    # create map of S3 key to local file location
    files = Hash.new

    # add xml file to list of files to be uploaded to S3
    files[book_uid + "/" + content] = contents_filename

    # add image to list of files to be uploaded
    each_image(doc) do |image_node|
      image_location = image_node['src']
      # only want to upload images that have a src attribute
      if (image_location)
        files[book_uid + "/" + image_location] = File.join(book_directory, image_location)
      end
    end
    #puts ("pre thread pool is #{number_to_human_size(`ps -o rss= -p #{Process.pid}`.to_i)}")
    #upload the files, if they have not been previously uploaded, to s3 in parallel
    Parallel.map(files.keys, :in_threads => 2) do |file_key|
      #puts ("begin thread memory is #{number_to_human_size(`ps -o rss= -p #{Process.pid}`.to_i)}")
      # upload files
        s3_object = bucket.objects[file_key]
        begin
          if (! s3_object.exists?)
            file_location = files[file_key]
            if(File.exists?(file_location))
              s3_object.write(:file => file_location)
            else
              #puts("file does not exist in local dir #{file_location}")
              s3_object = nil
            end
          else
            #puts ("#{image_location} already exists")
          end
        rescue AWS::Errors::Base => e
          puts "S3 credentials incorrect"
        end
      s3_object = nil
      #puts ("end thread memory is #{number_to_human_size(`ps -o rss= -p #{Process.pid}`.to_i)}")
    end
    bucket = nil
    s3_service = nil
  end

  def get_xml_from_dir (book_directory)
    contents_filename = get_daisy_contents_xml_name(book_directory)
    File.read(contents_filename)
  end

  def get_daisy_contents_xml_name(book_directory)
    Dir.glob(File.join(book_directory, '*.xml'))[0]
  end

  def each_image (doc)
    images = doc.xpath( doc, "//xmlns:img")
    images.each do | image_node |
      yield(image_node)
    end
  end

  def extract_book_uid(doc)
    xpath_uid = "//xmlns:meta[@name='dtb:uid']"
    matches = doc.xpath(doc, xpath_uid)
    if matches.size != 1
      raise MissingBookUIDException.new
    end
    node = matches.first
    return node.attributes['content'].content
  end

  def extract_optional_book_title(doc)
    xpath_title = "//xmlns:meta[@name='dc:Title']"
    matches = doc.xpath(doc, xpath_title)
    if matches.size != 1
      return nil
    end
    node = matches.first
    return node.attributes['content'].content
  end

  def get_image_size(book_directory, image_location)
    width, height = 20

    image_file = File.join(book_directory, image_location)
    if File.exists?(image_file)
      open(image_file, "rb") do |fh|
          is = ImageSize.new(fh.read)
          width = is.width
          height = is.height
      end
    end

    return width, height
  end


  def before(job)
    puts 'before'
  end

  def after(job)
    puts 'after'
  end

  def success(job)
    puts "job successfully completed"
  end

  def error(job, exception)
    puts "#{exception.class}: #{exception.message}"
      puts exception.backtrace.join("\n")
      $stderr.puts exception
  end

  def failure
    puts "some sort of failure"
  end

  def unzip
    #another way to trigger a delayed job
  end
  handle_asynchronously :unzip

end