class AddMissingLibraryIndex < ActiveRecord::Migration
  def self.up
    add_index :dynamic_images, [:book_id, :image_location], :name => 'index_dynamic_images_on_book_id_and_image_location'
    add_index :libraries, [:name], :name => 'idx_library_name_unique', :unique => true
  end

  def self.down
  end
end
