class CreateBookFragments < ActiveRecord::Migration
  def self.up
    create_table :book_fragments do |t|
      t.timestamps
      t.integer :book_id
      t.integer :sequence_number # order of fragment
    end
    add_constraint 'book_fragments', 'book_fragments_book_id', 'book_id', 'books', 'id'
    
    execute "insert into book_fragments (created_at, updated_at, book_id, sequence_number) select now(), now(), id, 1 from books"
    
    change_table :dynamic_images do |t|
      t.integer :book_fragment_id
    end
    add_constraint 'dynamic_images', 'dynamic_images_book_frag_id', 'book_fragment_id', 'book_fragments', 'id'
    execute "update dynamic_images set book_fragment_id = (select id from book_fragments where book_fragments.book_id = dynamic_images.book_id limit 1)"
    
    # Grab the HTML for each book from S3
    repository = RepositoryChooser.choose
    
    Book.all.each do |book|
      file_name = book.uid + ".html"
      html = repository.get_cached_html(book.uid, file_name) rescue nil
      if (html)
        # save the HTML file back
        # write the doc.to_html to a temp file, then pass the temp file path to the store_file method
        file = Tempfile.new(book.uid, :encoding => html.encoding)
        
        file.write html
        file.flush
        repository.remove_file(book.uid + "/" + book.uid + ".html")
        repository.store_file(file.path, book.uid, "#{book.uid}/#{book.uid}_1.html", nil)
        
        file.close
      end
    end
  end

  def self.down
    add_constraint 'dynamic_images', 'dynamic_images_book_frag_id'
    change_table :dynamic_images do |t|
      t.remove :book_fragment_id
    end
    drop_table :book_fragments
  end
end
