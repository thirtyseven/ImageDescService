class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :id
      t.integer :book_id , :null => false
      t.string :image_id , :null => false
      t.string :isbn , :limit => 13
      t.integer :page_number
      t.integer :sequence_number
      t.string :caption , :limit => 8192
      t.string :url
      t.references :library

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
