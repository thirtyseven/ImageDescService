class SwapUidForBookid < ActiveRecord::Migration
  def self.up
    change_table :book_stats do |t|
      t.integer :book_id
    end
    change_table :dynamic_descriptions do |t|
      t.integer :book_id
    end
    change_table :dynamic_images do |t|
      t.integer :book_id
    end
    
    execute "update book_stats set book_id = (select id from books where uid = book_uid)"
    execute "update dynamic_descriptions set book_id = (select id from books where uid = book_uid)"
    execute "update dynamic_images set book_id = (select id from books where uid = book_uid)"

    change_table :book_stats do |t|
      t.remove :book_uid
      t.remove :book_title
    end
    change_table :dynamic_descriptions do |t|
      t.remove :book_uid
    end
    change_table :dynamic_images do |t|
      t.remove :book_uid
      t.remove :book_title
    end
  end

  def self.down
  end
end
