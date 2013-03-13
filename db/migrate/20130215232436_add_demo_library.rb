class AddDemoLibrary < ActiveRecord::Migration
  def self.up
    ["Demo"].each {|name|  Library.create(:name => name) unless Library.exists?(:name => name)}  
  end

  def self.down
  end
end
