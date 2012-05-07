class BlankOutTheSrcAttributeOfImages < ActiveRecord::Migration
  include RepositoryChooser
  def self.up
    # Grab the HTML for each book from S3
    repository = RepositoryChooser.choose
    
    
    Book.all.each do |book|
      file_name = book.uid + ".html"
      html = repository.get_cached_html(book.uid, file_name) rescue nil
      if (html)
        doc = Nokogiri::HTML(html)
        # Remove the img src attribute from the saved HTML
        doc.css('img').each {|node| node['src'] = ''}
        
        # save the HTML file back
        # write the doc.to_html to a temp file, then pass the temp file path to the store_file method
        file = Tempfile.new(book.uid)
        
        file.write doc.to_html
        file.flush
        repository.remove_file(book.uid + "/" + book.uid + ".html")
        repository.store_file(file.path, book.uid, book.uid + "/" + book.uid + ".html", nil)
        
        file.close
      end
    end
  end

  def self.down
  end
end
