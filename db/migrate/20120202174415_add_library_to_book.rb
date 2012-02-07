class AddLibraryToBook < ActiveRecord::Migration
  def self.up
     add_column :books, :library_id, :integer,  :null => false
  end

  def self.down
    remove_column :books, :library_id
  end
end
