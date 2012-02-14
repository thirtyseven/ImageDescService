class AddInitialLibrary < ActiveRecord::Migration
  def self.up  
      Library.create :name => "Bookshare"
      execute "delete from libraries where name = \"test library\""  
      execute "update books set library_id = (select id from libraries limit 1)" 
      execute "insert into user_libraries (created_at, updated_at, user_id, library_id) select now(), now(), id, (select id from libraries limit 1) library_id from users" 
  end

  def self.down
  end
end
