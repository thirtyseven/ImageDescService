class AddDescribedIndexToDynamicImages < ActiveRecord::Migration
  def self.up
    add_index :dynamic_images, [:book_uid, :should_be_described]
  end

  def self.down
    remove_index :dynamic_images, [:book_uid, :should_be_described]
  end
end