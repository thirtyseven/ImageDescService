class Description < ActiveRecord::Base
  validates :description, :length => { :maximum => 16384 } , :presence => true
  validates :submitter_id, :presence => true
  validates :image_id, :presence => true

  belongs_to :image
end
