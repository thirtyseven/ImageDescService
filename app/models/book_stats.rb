class BookStats < ActiveRecord::Base
  def self.create_book_row (book)
    book_stats = BookStats.find_by_book_uid(book.uid)

    if !(book_stats)
      book_stats = BookStats.new
      book_stats.book_uid = book.uid
      book_stats.book_title = book.title
    end
    book_stats.total_images = DynamicDescription.connection.select_value("select count(id) from dynamic_images where book_uid = '#{book.uid}'")
    book_stats.total_essential_images = DynamicImage.connection.select_value("select count(id) from dynamic_images where book_uid = '#{book.uid}' and should_be_described = true")
    book_stats.total_images_described = DynamicDescription.connection.select_value("select count(distinct(dynamic_image_id)) from dynamic_descriptions where book_uid = '#{book.uid}'")
    book_stats.essential_images_described = DynamicDescription.connection.select_value("SELECT count(id) FROM dynamic_images di,
    (select dynamic_image_id from dynamic_descriptions where dynamic_descriptions.book_uid = '#{book.uid}' and is_current = 1) as essential
    WHERE book_uid = '#{book.uid}' and should_be_described = true and di.id = essential.dynamic_image_id ;")
    book_stats.save!
  end
end