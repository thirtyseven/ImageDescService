class Book < ActiveRecord::Base
  self.per_page = 25

  validates :uid,  :presence => true, :length => { :maximum => 255 }
  validates :isbn, :length => { :maximum => 13 }

end
