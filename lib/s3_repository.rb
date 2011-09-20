module S3Repository
  def store_file (location, file_path, book_uid)
    # get handle to s3 service
        s3_service = AWS::S3.new
        # get an s3 bucket
        bucket = s3_service.buckets[location]

        s3_object = bucket.objects[book_uid + ".zip"]
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
          s3_object = nil
          s3_service = nil
          raise
        rescue Exception => e
          puts "Unknown problem uploading book to S3 for book #{book_uid}"
          puts "#{e.class}: #{e.message}"
          puts e.backtrace.join("\n")
          $stderr.puts e
          s3_object = nil
          s3_service = nil
          raise
        end
        s3_object = nil
        s3_service = nil
  end
end