ActiveAdmin.register Book do
  
  actions :index

  index do
    column :id  
    column  :uid do |book|
      link_to book.uid, reports_view_book_path(:book_id => book.id)
      end
    column   :title do |book|
      link_to book.title, edit_book_edit_path(:book_id => book.id)
      end
    column :isbn
    column :status
    column "Added", :created_at
    column  do |book| 
      div :class => :action do
        link_to "Mark All Essential", imageDesc_mark_all_essential_path(:book_id => book.id), :remote => true, :method => "post", :format => :js, :class => "book-link-ajax"
      end
    end
    column  do |book| 
      div :class => :action do
        link_to "Approve Image Description", books_mark_approved_path(:book_id => book.id), :remote => true, :method => "post", :format => :js, :class => "book-link-ajax"
      end
    end
  end
  
  filter :uid 
  filter :title
  filter :isbn
  
end
