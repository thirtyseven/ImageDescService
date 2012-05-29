class ChangeXmlIdToImageIdAndOriginal < ActiveRecord::Migration
  include RepositoryChooser
  def self.up
    # Grab the HTML for each book from S3
    repository = RepositoryChooser.choose
    
    Book.all.each do |book|
      
      image_srces = []
      book.book_fragments.all.each do |book_fragment|
        file_name = "#{book_fragment.book.uid}_#{book_fragment.sequence_number}.html"
        begin
          html = repository.get_cached_html(book_fragment.book.uid, file_name) rescue nil
          doc = Nokogiri::HTML(html)
      
          doc.css('img').each do |img_node| 
            unless (img_node['id']).blank?
              db_image = DynamicImage.where(:book_id => book.id, :xml_id => img_node['id']).first
              if db_image
                img_node['img-id'] = db_image.id.to_s
                img_node['original'] = image_srces.include?(img_node['id']) ? '0' : '1' 
              end
              image_srces << img_node['id']
            end
          end
          segment_html = doc.to_html
      
      
          if (segment_html)
            # save the HTML file back
            # write the doc.to_html to a temp file, then pass the temp file path to the store_file method
            file = Tempfile.new(file_name, :encoding => segment_html.encoding)
        
            file.write segment_html
            file.flush
            repository.remove_file("#{book_fragment.book.uid}/#{file_name}")
            repository.store_file(file.path, book_fragment.book.uid, "#{book_fragment.book.uid}/#{file_name}", nil)
        
            file.close
          end
        rescue Exception => e
          p "ESH: hit an exception with file #{file_name}, e=#{e.inspect}, trace=#{e.backtrace.inspect}"
        end
      end
    end
  end

  def self.down
  end
end
