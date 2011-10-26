class AddBookTitleToBookStats < ActiveRecord::Migration
  def self.up
    add_column :book_stats, :book_title, :string
  end

  def self.down
    remove_column :book_stats, :book_title
  end
end
