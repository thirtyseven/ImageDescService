class AddPublisherToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :publisher, :string
    add_column :books, :publisher_date, :date
  end

  def self.down
  end
end
