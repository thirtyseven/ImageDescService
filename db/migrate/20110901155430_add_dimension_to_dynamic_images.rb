class AddDimensionToDynamicImages < ActiveRecord::Migration
  def self.up
    add_column :dynamic_images, :width, :integer
    add_column :dynamic_images, :height, :integer
    add_index :dynamic_images, [:book_uid, :image_location]
  end

  def self.down
    remove_column :dynamic_images, :width, :integer
    remove_column :dynamic_images, :height, :integer
    remove_index :dynamic_images, [:book_uid, :image_location]
  end
end