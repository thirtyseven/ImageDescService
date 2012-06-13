class AddAnnotationToDescriptions < ActiveRecord::Migration
  def self.up
    add_column :dynamic_descriptions, :annotation, :text, :limit => 1024
  end

  def self.down
  end
end
