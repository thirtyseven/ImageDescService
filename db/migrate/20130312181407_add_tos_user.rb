class AddTosUser < ActiveRecord::Migration
  def self.up
      add_column :users, :agreed_tos, :boolean, :default => false
  end

  def self.down
  end
end
