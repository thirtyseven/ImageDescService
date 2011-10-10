class S3Repository
  require 'find'

  def self.store_file (file_path, book_uid, new_file_name, s3_service)
        bucket_name = ENV['POET_ASSET_BUCKET']
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

  def self.read_file(file_path, new_local_file)
      bucket_name = ENV['POET_ASSET_BUCKET']
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

  def self.remove_file(file_path)
      bucket_name = ENV['POET_ASSET_BUCKET']
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

  def self.xslt(xml, xsl, poet_host, form_authenticity_token)
    engine = XML::XSLT.new
    engine.xml = xml
    engine.xsl = xsl
    bucket_name = "/s3.amazonaws.com/" + ENV['POET_ASSET_BUCKET'].dup

    engine.parameters = {"form_authenticity_token" => form_authenticity_token, "bucket" => bucket_name, "poet_host" => poet_host}
    return engine.serve
  end

  def self.get_cached_html(book_uid, file_name)
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

  def self.get_host(request)
    return "//s3.amazonaws.com/" + ENV['POET_ASSET_BUCKET']
  end

end