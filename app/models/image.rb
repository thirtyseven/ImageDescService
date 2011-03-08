class Image < ActiveRecord::Base
  validates :book_id,  :presence => true
  validates :image_id,  :presence => true
  validates :isbn, :length => { :maximum => 13 }
  validates :caption, :length => { :maximum => 8192 }
  validates :url, :length => { :maximum => 255 }

  belongs_to :library
  has_many :descriptions
end
