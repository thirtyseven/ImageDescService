class AddApprovedDescriptionsToBookStats < ActiveRecord::Migration
  def self.up
    add_column :book_stats, :approved_descriptions, :integer, :default => 0
  end

  def self.down
    remove_column :book_stats, :approved_descriptions
  end
end
