class Book < ActiveRecord::Base
  paginates_per 25

  validates :uid,  :presence => true, :length => { :maximum => 255 }
  validates :isbn, :length => { :maximum => 13 }
  
  has_many :dynamic_descriptions
  has_many :dynamic_images
  has_many :book_stats, :class_name => 'BookStats', :foreign_key => :book_id, :dependent => :destroy
  has_many :book_fragments, :dependent => :destroy
  belongs_to :library

  def mark_approved

    # set the latest descriptions as current (approved)
    begin
      DynamicDescription.update_all({:is_current => false}, {:book_id => self.id})
      # TODO ESH: may be able to AREL-ize this:
      Book.connection.execute("update dynamic_descriptions set is_current = 1, date_approved = now() where id in (select id from
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
    dynamic_images.includes(:dynamic_descriptions).where(:dynamic_descriptions => {:is_current => true}).group('dynamic_descriptions.id')
  end
  
  def book_stats_plus_unessential_images_described
    book_stats.select("book_stats.*, total_images_described - essential_images_described as unessential_images_described") 
  end
  
  def status_to_english
    case status
      when 0
        'Expired'
      when 1
        'Processing Images'
      when 2
        'Processing Book'
      when 3
        'Complete'
      else
        'Processing'
    end
  end
end