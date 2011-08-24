class AddShouldBeDescribedColumn < ActiveRecord::Migration
  def self.up
    add_column :dynamic_images, :should_be_described, :boolean
  end

  def self.down
    remove_column :dynamic_images, :should_be_described
  end
end
