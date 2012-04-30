class ReformatBookHtml < ActiveRecord::Migration
  include RepositoryChooser

  def self.up
    # Grab the HTML for each book from S3
    repository = RepositoryChooser.choose
    
    
    Book.all.each do |book|
      html = repository.get_cached_html(book.uid, book.xml_file)
      if (html)
        doc = Nokogiri::HTML(html)
        # Remove the javascript injected at the beginning of the file
        doc.css('script').each {|node| node.remove}
        # Remove the HTML nodes injected around the IMG
        doc.css('.imggroup br').each {|node| node.remove}
        doc.css('.imggroup div').each {|node| node.remove}
        
        # save the HTML file back
        # TODO ESH: write the doc.to_html to a temp file, then pass the temp file path to the store_file method
        file = Tempfile.new(book.uid)
        
        file.write doc.to_html
        file.close
        repository.store_file(file.path, book.uid, book.xml_file, nil)
      end
    end
  end

  def self.down
  end
end
