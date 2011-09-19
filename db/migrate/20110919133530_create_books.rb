class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :uid, :null => false
      t.string :title
      t.string :isbn , :limit => 13
      t.integer :status

      t.timestamps
    end

    add_index :books, [:uid]
    add_index :books, [:title]
    add_index :books, [:isbn]
  end

  def self.down
    drop_table :books
    remove_index :books, [:uid]
    remove_index :books, [:title]
    remove_index :books, [:isbn]
  end
end