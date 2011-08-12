class RenameUidToBookUid < ActiveRecord::Migration
  def self.up
    rename_column :dynamic_images, :uid, :book_uid
  end

  def self.down
    rename_column :dynamic_images, :book_uid, :uid
  end
end
