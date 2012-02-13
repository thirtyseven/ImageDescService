class MakeBookUidAUniqueKey < ActiveRecord::Migration
  def self.up
    remove_index :books, :name => 'index_books_on_uid'
    add_index :books, :uid, :unique => true
  end

  def self.down
  end
end
