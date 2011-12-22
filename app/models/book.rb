class Book < ActiveRecord::Base
  paginates_per 25

  validates :uid,  :presence => true, :length => { :maximum => 255 }
  validates :isbn, :length => { :maximum => 13 }
  
  has_many :dynamic_descriptions
  has_many :dynamic_images
  has_many :book_stats

  def mark_approved

    # set the latest descriptions as current (approved)
    begin
      DynamicDescription.update_all({:is_current => false}, {:book_id => self.id})
      # TODO ESH: may be able to AREL-ize this:
      Book.connection.execute("update dynamic_descriptions set is_current = 1 where id in (select id from
         (select max(id) as id from dynamic_descriptions where book_id = '#{self.id}' group by dynamic_image_id) temptable)")
    rescue Exception => e
      puts e.message
      logger.info "#{e.class}: #{e.message}"
    end

    # set approved flag at the book level
    update_attribute("last_approved", Time.now)

    # update the stats for this book
    BookStats.create_book_row(self)
  end

  def current_images_and_descriptions
    # TODO ESH: test and remove this:
    # Used to be:
    # @results = DynamicDescription.connection.select_all("select i.image_location, d.body from dynamic_images i
    #  left join dynamic_descriptions d on i.id = d.dynamic_image_id where d.book_uid = '#{params[:book_uid]}' and d.is_current = 1")
    
    dynamic_images.includes(:dynamic_descriptions).where(:dynamic_descriptions => {:is_current => true}).select('dynamic_images.image_location, dynamic_descriptions.body')
  end
end