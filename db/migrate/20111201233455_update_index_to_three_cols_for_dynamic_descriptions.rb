class UpdateIndexToThreeColsForDynamicDescriptions < ActiveRecord::Migration
  def self.up
    remove_index :dynamic_descriptions, [:book_uid, :dynamic_image_id]
    add_index :dynamic_descriptions, [:book_uid, :dynamic_image_id, :is_current], {:name => "dynamic_descriptions_uid_image_id_current"}
  end

  def self.down
    add_index :dynamic_descriptions, [:book_uid, :dynamic_image_id]
    remove_index(:dynamic_descriptions, :name => "dynamic_descriptions_uid_image_id_current")
  end
end
