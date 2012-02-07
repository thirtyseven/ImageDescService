class RemoveFieldsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :address  
    remove_column :users, :telephone  
    remove_column :users, :bookshare_volunteer
  end

  def self.down
    add_column :users, :address, :string
    add_column :users, :telephone, :string
    add_column :users, :bookshare_volunteer, :boolean, :default => false
  end
end


   
