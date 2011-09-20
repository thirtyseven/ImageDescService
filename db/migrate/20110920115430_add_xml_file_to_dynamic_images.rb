class AddXmlFileToDynamicImages < ActiveRecord::Migration
  def self.up
    add_column :books, :xml_file, :string , :null => false, :default => 'none'
  end

  def self.down
    remove_column :books, :xml_file
  end
end