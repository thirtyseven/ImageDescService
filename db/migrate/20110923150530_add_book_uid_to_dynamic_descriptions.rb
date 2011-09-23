class AddBookUidToDynamicDescriptions < ActiveRecord::Migration
  def self.up
    add_column :dynamic_descriptions, :book_uid, :string
    add_index :dynamic_descriptions, [:book_uid, :dynamic_image_id]
  end

  def self.down
    remove_index :dynamic_descriptions, [:book_uid, :dynamic_image_id]
    remove_column :dynamic_descriptions, :book_uid
  end
end