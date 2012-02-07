class AddInitialRoles < ActiveRecord::Migration
  def self.up
    ["Admin", "Moderator", "Describer"].each {|name|  Role.create :name => name}     
  end

  def self.down
  end
end
