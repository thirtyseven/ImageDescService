class AddFieldsToUser < ActiveRecord::Migration
  def self.up
     add_column :users, :first_name, :string
     add_column :users, :last_name, :string
     add_column :users, :address, :string
     add_column :users, :geo_city, :string
     add_column :users, :geo_state, :string
     add_column :users, :zip_code, :string
     add_column :users, :telephone, :string
     add_column :users, :other_subject_expertise, :string
     #new book store volunteer?
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :address
    remove_column :users, :geo_city
    remove_column :users, :geo_state
    remove_column :users, :zip_code
    remove_column :users, :telephone
    remove_column :users, :other_subject_expertise
  end
  
end
