class ResizeExistingImages < ActiveRecord::Migration
  include RepositoryChooser

  def self.up
    repository = RepositoryChooser.choose

    begin

      DynamicImage.all.each do |image|
        if (image.book)

          book_file_name = image.book.uid + ".html"
          html = repository.get_cached_html(image.book.uid, book_file_name) rescue nil
          if (html)

            FileUtils.makedirs(File.join("", "tmp", image.book.uid, "images"))
            file_name = ::File.join("", "tmp", image.book.uid, image.image_location)

            local_file = repository.read_file(image.book.uid + "/" + image.image_location, file_name)
            if local_file
              actual_file = File.open(local_file, "rb")
              puts "#{local_file} found"
              image.update_attribute("physical_file", actual_file)
            end

          end
        end
      end

      rescue Exception => e
        puts "Unknown problem resizing existing images"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace.join("\n")
        $stderr.puts e

    end
  end

  def self.down
  end
end
