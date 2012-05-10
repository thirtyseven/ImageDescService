class AddPhysicalFileColumnsToDynamicImage < ActiveRecord::Migration
  def self.up
    change_table :dynamic_images do |t|
      t.has_attached_file :physical_file
    end
  end

  def self.down
    drop_attached_file :dynamic_images, :physical_file
  end
end
