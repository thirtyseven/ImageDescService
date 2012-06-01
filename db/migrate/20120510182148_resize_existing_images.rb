class ResizeExistingImages < ActiveRecord::Migration
  include RepositoryChooser

  def self.up
      repository = RepositoryChooser.choose
                       #Client.where(:orders_count => [1,3,5])
      #Client.limit(5).offset(30)
      begin

        begin
          repository = RepositoryChooser.choose
          DynamicImage.where("book_id > 28 and book_id < 31 and isnull(physical_file_file_name)").each do |image|
            if (image.book )

              book_file_name = image.book.uid + ".html"
              puts "book file name is #{book_file_name}"
              html = repository.get_cached_html(image.book.uid, book_file_name) rescue nil
              if (html)
                puts "in if statement"
                FileUtils.makedirs(File.join("", "tmp", image.book.uid, "images"))
                file_name = ::File.join("", "tmp", image.book.uid, image.image_location)

                local_file = repository.read_file(image.book.uid + "/" + image.image_location, file_name)
                if local_file
                  actual_file = File.open(local_file, "rb")
                  puts "#{local_file} found"
                  image.update_attribute("physical_file", actual_file)
                  File.delete(local_file)
                end

              end
            end
          end
          int i = 3
        end

      end
    end

  def self.down
  end
end
