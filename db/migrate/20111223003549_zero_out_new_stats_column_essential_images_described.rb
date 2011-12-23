class ZeroOutNewStatsColumnEssentialImagesDescribed < ActiveRecord::Migration
  def self.up
    execute "update book_stats set essential_images_described=0"
    change_column :book_stats, :essential_images_described, :integer, :default => 0
  end

  def self.down
  end
end
