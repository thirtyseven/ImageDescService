class Book < ActiveRecord::Base
  self.paginates_per = 25

  validates :uid,  :presence => true, :length => { :maximum => 255 }
  validates :isbn, :length => { :maximum => 13 }

  def mark_approved

    # set the latest descriptions as current (approved)
    begin
      Book.connection.execute("update dynamic_descriptions set is_current = 0 where book_uid = '#{uid}'")
      Book.connection.execute("update dynamic_descriptions set is_current = 1 where id in (select id from
         (select max(id) as id from dynamic_descriptions where book_uid = '#{uid}' group by dynamic_image_id) temptable)")
    rescue Exception => e
      puts e.message
      logger.info "#{e.class}: #{e.message}"
    end

    # set approved flag at the book level
    update_attribute("last_approved", Time.now)

    # update the stats for this book
    BookStats.create_book_row(self)
  end

end
