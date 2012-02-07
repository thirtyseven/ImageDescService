class CreateUserLibraries < ActiveRecord::Migration
  def self.up
    create_table :user_libraries do |t|
      t.integer :user_id
      t.integer :library_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_libraries
  end
end
