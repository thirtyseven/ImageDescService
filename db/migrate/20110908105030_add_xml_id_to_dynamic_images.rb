class AddXmlIdToDynamicImages < ActiveRecord::Migration
  def self.up
    add_column :dynamic_images, :xml_id, :string
  end

  def self.down
    remove_column :dynamic_images, :xml_id
  end
end