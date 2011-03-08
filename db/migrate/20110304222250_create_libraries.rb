class CreateLibraries < ActiveRecord::Migration
  def self.up
    create_table :libraries do |t|
      t.integer :id
      t.string :name , :limit => 128 , :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :libraries
  end
end
