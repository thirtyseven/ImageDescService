class Library < ActiveRecord::Base
  validates :name,  :presence => true ,
                    :length => { :maximum => 128 }

  has_many :books
  has_many :images
  has_many :user_libraries
  has_many :users, :through => :user_libraries
  
  def related_books
    Book.where(:library_id => self.id).readonly(false)
  end
  
  def related_users
     User.joins(:user_libraries).where('user_libraries.library_id' => self.id).readonly(false)
  end
  
  def related_book_stats
     BookStats.joins(:book => :library).where(:libraries => {:id => self.id}).readonly(false)
  end  
  
end
