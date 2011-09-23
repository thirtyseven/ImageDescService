class UpdateBookUidToDynamicDescriptions < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      UPDATE dynamic_descriptions set book_uid = (SELECT book_uid from dynamic_images where dynamic_images.id = dynamic_image_id)
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE dynamic_descriptions set book_uid = null
    SQL
  end
end