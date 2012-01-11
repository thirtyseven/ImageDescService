class AddPercentEssentialDescribed < ActiveRecord::Migration
  def self.up
      add_column :book_stats, :percent_essential_described, :decimal, :default => 0.0
    end

    def self.down
      remove_column :book_stats, :percent_essential_described
    end
end
