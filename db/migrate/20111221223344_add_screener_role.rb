class AddScreenerRole < ActiveRecord::Migration
  def self.up  
       Role.create!(:name => 'Screener')
  end

  def self.down
  end
end
