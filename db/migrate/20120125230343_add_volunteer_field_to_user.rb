class AddVolunteerFieldToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :bookshare_volunteer, :boolean, :default => false
  end

  def self.down
    remove_column :users, :bookshare_volunteer
  end
end
