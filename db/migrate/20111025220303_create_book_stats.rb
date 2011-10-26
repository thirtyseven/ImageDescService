class CreateBookStats < ActiveRecord::Migration
  def self.up
    create_table :book_stats do |t|
      t.string :book_uid
      t.integer :total_images
      t.integer :total_essential_images, :default => 0
      t.integer :total_images_described, :default => 0
    end
  end

  def self.down
    drop_table :book_stats
  end
end
