class AddImageIndexToDynamicDescriptions < ActiveRecord::Migration
  def self.up
    add_index :dynamic_descriptions, [:dynamic_image_id]
  end

  def self.down
    remove_index :dynamic_descriptions, [:dynamic_image_id]
  end
end