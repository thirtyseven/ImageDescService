class DynamicDescription < ActiveRecord::Base
  validates :body, :length => { :minimum => 2, :maximum => 16384 } , :presence => true
  validates :submitter, :length => { :maximum => 255 }
  validates :dynamic_image_id, :presence => true

  belongs_to :dynamic_image
  belongs_to :book

  def as_json(options={})
    { :body => body # just use the attribute when no helper is needed
    }
  end
end
