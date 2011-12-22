require 'xml/xslt'

class S3UnzippingJob < Struct.new(:book_uid, :poet_host, :form_authenticity_token, :repository)

  def enqueue(job)

  end

  def perform
    begin
        daisy_file = repository.read_file(book_uid + ".zip", File.join( "", "tmp", "#{book_uid}.zip"))
        book_directory = accept_book(daisy_file)

        xml = get_xml_from_dir(book_directory)
        doc = Nokogiri::XML xml
        opf = get_opf_from_dir(book_directory)
        contents_filename = get_daisy_contents_xml_name(book_directory)
        p "ESH: 1111 #{book_uid}"
        book = create_book_in_db(doc, File.basename(contents_filename), opf)
        p "ESH: 2222 #{book_uid}"

        create_images_in_database(book_directory, doc)
        p "ESH: 3333 #{book_uid}"
        book.update_attribute("status", 2)
        p "ESH: 4444 #{book_uid}"
        upload_files_to_s3(book_directory, doc)
        p "ESH: 5555 #{book_uid}"

        xsl_filename = 'app/views/xslt/daisyTransform.xsl'
        p "ESH: 6666 #{book_uid}"
        xsl = File.read(xsl_filename)
        p "ESH: 7777 #{book_uid}"
        contents = repository.xslt(xml, xsl, poet_host, form_authenticity_token)
        p "ESH: 8888 #{book_uid}"
        content_html = File.join("","tmp", "#{book_uid}.html")
        p "ESH: 9999 #{book_uid}"
        File.open(content_html, 'wb'){|f|f.write(contents)}
        p "ESH: 10000 #{book_uid}"
        repository.store_file(content_html, book_uid, book_uid + "/" + book_uid + ".html", nil)
        p "ESH: 11000 #{book_uid}"

        book.update_attribute("status", 3)
        p "ESH: 12000 #{book_uid}"

        doc = nil
        xml = nil

        # remove zip file from holding bucket
        repository.remove_file(book_uid + ".zip")

        p "ESH: 13000 #{book_uid}"
        daisy_file = nil
      rescue Exception => e
          puts "Unknown problem in unzipping job for book #{book_uid}"
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

  def create_book_in_db(doc, xml_file, opf)
    isbn = nil
    if (opf)
      opf_doc = Nokogiri::XML opf
      isbn = extract_optional_isbn(opf_doc)
    end
    @book_title = extract_optional_book_title(doc)
    book = Book.where(:uid => book_uid).first
    if (!book)
      book = Book.create(
          :uid => book_uid,
          :title => @book_title,
          :status => 1,
          :isbn => isbn,
          :xml_file => xml_file
      )
    elsif (!xml_file.eql?(book.xml_file))
      book.update_attributes(:xml_file => xml_file, :status => 1)
    end
    return book
  end

  def create_images_in_database(book_directory, doc)
    book = Book.where(:uid => book_uid).first
    each_image(doc) do | image_node |
      image_location = image_node['src']
      xml_id = image_node['id']

      # if src exists
      if (image_location)

        # add image to db if it does not already exist in db
        image = DynamicImage.where(:book_id => book.id, :image_location => image_location).first
        if(!image && File.exists?(File.join(book_directory, image_location)))
          width, height = get_image_size(book_directory, image_location)
          DynamicImage.create(
                :book_id => book.id,
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

    s3_service = nil
    if (!ENV['POET_LOCAL_STORAGE_DIR'])
      # get handle to s3 service
      s3_service = AWS::S3.new
    end

    # upload image to S3
    each_image(doc) do |image_node|
      image_location = image_node['src']
      # only want to upload images that have a src attribute
      if (image_location)
        file_key = book_uid + "/" + image_location
        file_location = File.join(book_directory, image_location)

        #puts ("begin thread memory is #{number_to_human_size(`ps -o rss= -p #{Process.pid}`.to_i)}")
        repository.store_file(file_location, book_uid, file_key, s3_service)
      end
    end
  end

  def get_xml_from_dir (book_directory)
    contents_filename = get_daisy_contents_xml_name(book_directory)
    File.read(contents_filename)
  end

  def get_daisy_contents_xml_name(book_directory)
    Dir.glob(File.join(book_directory, '*.xml'))[0]
  end

  def get_opf_from_dir (book_directory)
    opf_filename =  get_opf_name(book_directory)
    File.read(opf_filename)
  end

  def get_opf_name(book_directory)
    Dir.glob(File.join(book_directory, '*.opf'))[0]
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

  def extract_optional_isbn(doc)
    matches = doc.xpath("//dc:Identifier[@scheme='ISBN']", 'dc' => 'http://purl.org/dc/elements/1.1/')
    if matches.size != 1
      return nil
    end
    node = matches.first
    return node.text
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