class DynamicImage < ActiveRecord::Base
  validates_presence_of :book_id
  validates :image_location,  :presence => true, :length => { :maximum => 255 }

  has_many :dynamic_descriptions
  
  def best_description
    return dynamic_descriptions.last
  end
end
