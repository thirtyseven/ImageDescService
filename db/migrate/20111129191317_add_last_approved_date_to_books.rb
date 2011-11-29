class AddLastApprovedDateToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :last_approved, :datetime
  end

  def self.down
    remove_column :books, :last_approved
  end
end
