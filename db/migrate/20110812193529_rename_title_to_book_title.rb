class RenameTitleToBookTitle < ActiveRecord::Migration
  def self.up
    rename_column :dynamic_images, :title, :book_title
  end

  def self.down
    rename_column :dynamic_images, :book_title, :title
  end
end
