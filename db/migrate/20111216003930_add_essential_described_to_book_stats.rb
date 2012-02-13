class AddEssentialDescribedToBookStats < ActiveRecord::Migration
  def self.up
    add_column :book_stats, :essential_images_described, :integer
  end

  def self.down
    remove_column :book_stats, :essential_images_described
  end
end
