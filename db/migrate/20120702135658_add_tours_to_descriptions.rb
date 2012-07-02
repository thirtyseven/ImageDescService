class AddToursToDescriptions < ActiveRecord::Migration
  def self.up
    add_column :dynamic_descriptions, :tactile_src, :string
    add_column :dynamic_descriptions, :tactile_tour, :text, :limit => 4096
    add_column :dynamic_descriptions, :simplified_image_src, :string
    add_column :dynamic_descriptions, :simplified_image_tour, :text, :limit => 4096
  end

  def self.down
  end
end
