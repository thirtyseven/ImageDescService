module S3Repository
  require 'find'

  def store_file (bucket_name, file_path, book_uid, new_file_name, s3_service)
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    if (local_dir)
      begin
        if (File.exists?(file_path))
          qualified_new_file = File.join(local_dir, new_file_name)
          dir = File.dirname(qualified_new_file)

          make_nested_dirs(dir, local_dir)

          FileUtils.copy_entry(file_path, qualified_new_file)
        else
          puts "file does not exist in local dir #{file_path} for copy to local store"
        end
      rescue Exception => e
         puts "Unknown problem copying to local storage dir for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
      end
    else
        if (!s3_service)
          # get handle to s3 service
          s3_service = AWS::S3.new
        end
        # get an s3 bucket
        bucket = s3_service.buckets[bucket_name]

        s3_object = bucket.objects[new_file_name]
        begin
          if (! s3_object.exists?)
            if(File.exists?(file_path))
              s3_object.write(:file => file_path)
            else
              puts("file does not exist in local dir #{file_path}")
              s3_object = nil
            end
          else
            #puts ("zip file already exists")
          end
        rescue AWS::Errors::Base => e
          puts "S3 Problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        rescue Exception => e
          puts "Unknown problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
        end
    end
  end

  def read_file(bucket_name, file_path, new_local_file)
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    if (local_dir)
      qualified_file = File.join(local_dir, file_path)
      if (File.exists?(qualified_file))
        dir = File.dirname(new_local_file)
        if (! File.exists?(dir))
          Dir.mkdir(dir)
        end
        FileUtils.copy_entry(qualified_file, new_local_file)
      else
        puts ("local file  to read doesn't exist, #{qualified_file}'")
      end
      return new_local_file
    else
      begin
        # get handle to s3 service
        s3_service = AWS::S3.new

        # get s3 bucket to download zip file
        bucket = s3_service.buckets[bucket_name]
        s3_object = bucket.objects[file_path]
        File.open(new_local_file, 'wb') {|f| f.write(s3_object.read) }
        rescue AWS::Errors::Base => e
          puts "S3 Problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        rescue Exception => e
          puts "Unknown problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
      end

      return new_local_file
    end
  end

  def remove_file(bucket_name, file_path)
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    if (local_dir)
      File.delete(File.join(local_dir, file_path))
    else
      begin
        # get handle to s3 service
        s3_service = AWS::S3.new

        # get s3 bucket to download zip file
        bucket = s3_service.buckets[bucket_name]
        s3_object = bucket.objects[file_path]
        s3_object.delete
        rescue AWS::Errors::Base => e
          puts "S3 Problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts "Line #{e.line}, Column #{e.column}, Code #{e.code}"
        rescue Exception => e
          puts "Unknown problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
      end
    end
  end

  def xslt(xml, xsl, poet_host)
    engine = XML::XSLT.new
    engine.xml = xml
    engine.xsl = xsl
    bucket_name = "/s3.amazonaws.com/" + ENV['POET_ASSET_BUCKET'].dup
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    if (local_dir)
      bucket_name = "/" + poet_host + "/daisy_book/book"
    end
    engine.parameters = {"form_authenticity_token" => form_authenticity_token, "bucket" => bucket_name, "poet_host" => poet_host}
    return engine.serve
  end

  def get_html_from_s3(book_uid, file_name)
    local_dir = ENV['POET_LOCAL_STORAGE_DIR']
    if (local_dir)
      return File.read(File.join(local_dir, book_uid, file_name))
    else
      # get handle to s3 service
      s3_service = AWS::S3.new
      # get an s3 bucket
      bucket = s3_service.buckets[ENV['POET_ASSET_BUCKET']]
      s3_object = bucket.objects[book_uid + "/" + file_name]
      if (s3_object.exists?)
        s3_object.read
      else
        return nil
      end
    end
  end

  def make_nested_dirs (nested_dir, root_dir)
    dirs = nested_dir.split(File::SEPARATOR)
    root_dirs = root_dir.split(File::SEPARATOR)
    root_dir_nest = root_dirs.size
    new_dir = "";
    dirs.each_index do |i|
      dir = dirs[i]
      new_dir = File.join(new_dir, dir)
      if (i >= root_dir_nest)
        if (! File.exists?(new_dir))
          Dir.mkdir(new_dir)
        end
      end
    end
  end

end