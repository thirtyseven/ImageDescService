class DynamicImage < ActiveRecord::Base
  validates :book_uid,  :presence => true, :length => { :maximum => 255 }
  validates :image_location,  :presence => true, :length => { :maximum => 255 }
  validates :book_title, :length => { :maximum => 255 }

  has_many :dynamic_descriptions
  
  def best_description
    return dynamic_descriptions.last
  end
end
