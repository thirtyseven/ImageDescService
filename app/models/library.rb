class Library < ActiveRecord::Base
  validates :name,  :presence => true ,
                    :length => { :maximum => 128 }

  has_many :images
end
