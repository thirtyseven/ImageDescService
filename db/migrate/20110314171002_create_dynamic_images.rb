class CreateDynamicImages < ActiveRecord::Migration
  def self.up
    create_table :dynamic_images do |t|
      t.string :uid
      t.string :title
      t.string :image_location , :limit => 255

      t.timestamps
    end
  end

  def self.down
    drop_table :dynamic_images
  end
end
