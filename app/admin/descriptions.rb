ActiveAdmin.register Book, :as => "BookDescriptions" do  
  menu :if => proc{ can? :admin_user, @all }
  scope_to :current_library, :association_method => :related_books_by_description
  
  
   actions :index
    

    index do
      
      column  :uid 
      
      column  :title 
      
      column "Total Images" do |book|
         num_images = Book.connection.select_value "select count(*) from dynamic_images di where di.book_id = #{book.id}"  
         num_images.to_s
      end  

      column "Approved Descriptions" do |book|
        DynamicDescription.where(:book_id => book.id, :submitter_id => book.submitter_id).where('date_approved is not null').count.to_s
      end
      
      column "Described by" do |book|
          described_by = Book.connection.select_value "select email from users where id = #{book.submitter_id} and deleted_at is not null" if book.submitter_id
          described_by.to_s
      end
      
      column "# Images Described" do |book|
        DynamicDescription.where(:book_id => book.id, :submitter_id => book.submitter_id).count.to_s
      end
      
      column "Edit Descriptions" do |book|
        unapproved_description_ids = DynamicDescription.where(:book_id => book.id, :submitter_id => book.submitter_id, :date_approved => nil).select(:id).map(&:id)
        if unapproved_description_ids.blank?
          "No unapproved images"
        else
           div :class => :action do
             link_to "Delete Unapproved Descriptions", delete_descriptions_by_id_path(:ids => unapproved_description_ids), :remote => true, :method => "post", :format => :js, :class => "delete-descriptions-link-ajax"
          end
        end
      end
    end
    
    filter :book_stats_percent_essential_described, :as => :numeric
    filter :title, as: :string, :label => 'Book Title'
    filter :uid, as: :string, :label => 'Book UID' 
    filter :dynamic_descriptions_submitter_email, :as => :select, :collection => proc {User.all.map(&:email)}, :label => "Image Describer Email"

end  