class DynamicDescription < ActiveRecord::Base
  validates :body, :length => { :minimum => 2, :maximum => 16384 } , :presence => true
  #validates :submitter, :length => { :maximum => 255 }
  validates :dynamic_image_id, :presence => true

  belongs_to :dynamic_image
  belongs_to :book
  belongs_to :submitter, :class_name => 'User', :foreign_key => :submitter_id
  before_save :remove_body_tag
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
  accepts_nested_attributes_for :dynamic_image, :allow_destroy => true
  
  index_name BONSAI_INDEX_NAME
  # TO RUN THE INDEX: bundle exec rake environment tire:import CLASS='DynamicDescription' FORCE=1 --trace
  
  # tire do
  #   mapping do
  #     indexes :body, :type => 'string'
  #   end
  # end
  
  settings :number_of_shards => 1,
           :number_of_replicas => 1,
           :analysis => {
                      :analyzer => {
                                 :str_search_analyzer => {
                                               :type => :custom,
                                               :tokenizer => :keyword,
                                               :filter => [:lowercase]
                                 },
                                 :str_index_analyzer => {
                                               :type => :custom,
                                               :tokenizer => :keyword,
                                               :filter => [:lowercase, :substring]
                                 }
                                 
                      },
                      :filter => {
                               :substring => {
                                          :type => "nGram",
                                          :min_gram => 3,
                                          :max_gram => 7
                               }
                      }
            }  do
    mapping do
      indexes :image_type, :as => 'DynamicDescription.connection.select_value("select dynamic_image.image_category_id from dynamic_images dynamic_image, dynamic_descriptions dyn_des where dyn_des.dynamic_image_id = dynamic_image.id and dyn_des.id = #{self.id}")'      
      indexes :dynamic_image_id, :type => 'integer'  
      indexes :isbn, :type => 'string', :index_analyzer => "str_index_analyzer", :search_analyzer => "str_search_analyzer", :as => 'DynamicDescription.connection.select_value("select book.isbn from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id and dyn_des.id = #{self.id}")'
      indexes :title, :type => 'string', :index_analyzer => "str_index_analyzer", :search_analyzer => "str_search_analyzer", :as => 'DynamicDescription.connection.select_value("select book.title from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id and dyn_des.id = #{self.id}")'
      indexes :body, :type => 'string', :index_analyzer => "str_index_analyzer", :search_analyzer => "str_search_analyzer"
      indexes :dynamic_description_library_id, :as => 'DynamicDescription.connection.select_value("select book.library_id from books book, dynamic_descriptions dyn_des where dyn_des.book_id = book.id and dyn_des.id = #{self.id}")'
      indexes :is_last_approved, :as => 'DynamicDescription.connection.select_value("select (select id from dynamic_descriptions inner_dd where inner_dd.dynamic_image_id = dynamic_descriptions.dynamic_image_id and date_approved is not null order by date_approved desc limit 1) = dynamic_descriptions.id from dynamic_descriptions where id = #{self.id}")'
    end
  end
  
  
  def as_json(options={})
    { :body => body # just use the attribute when no helper is needed
    }
  end
  
  def remove_body_tag
     self.body.gsub!(/&lt;body&gt;/i, '')
     self.body.gsub!(/&lt;\/body&gt;/i, '')
     self.body.gsub!(/&nbsp;/i , '&#160') 
  end
  
  def submitter_name
    if submitter 
      if !submitter.full_name.blank?
        submitter.full_name
      elsif !submitter.username.blank?
        submitter.username
      else 
        submitter.email
      end
    end
  end

end