class DynamicDescription < ActiveRecord::Base
  validates :body, :length => { :minimum => 2, :maximum => 16384 } , :presence => true
  validates :submitter, :length => { :maximum => 255 }
  validates :dynamic_image_id, :presence => true

  belongs_to :dynamic_image
  belongs_to :book
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  #bundle exec rake environment tire:import CLASS='DynamicDescription' FORCE=1
  def to_indexed_json
    {
      :body => self.body,
      :is_last_approved        => DynamicDescription.connection.select_value("select (select id from dynamic_descriptions inner_dd where inner_dd.dynamic_image_id = dynamic_descriptions.dynamic_image_id order by date_approved desc limit 1) = dynamic_descriptions.id from dynamic_descriptions where id = #{self.id}")
    }.to_json
  end
  

  def as_json(options={})
    { :body => body # just use the attribute when no helper is needed
    }
  end
end