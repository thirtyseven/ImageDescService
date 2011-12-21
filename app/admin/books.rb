ActiveAdmin.register Book do
  
  actions :index

  index do
    column :id  
    column  :uid do |book|
      link_to book.uid, reports_view_book_path(:book_uid => book.uid)
      end
    column   :title do |book|
      link_to book.title, edit_book_edit_path(:book_uid => book.uid)
      end
    column :isbn
    column :status
    column "Added", :created_at
    column  do |book| 
     link_to "Mark All Essential", imageDesc_mark_all_essential_path(:book_uid => book.uid), :remote => true, :method => "post", :format => :js, :class => "book-link-ajax"
     end
    column  do |book| 
     link_to "Approve Image Description", books_mark_approved_path(:book_id => book.uid), :remote => true, :method => "post", :format => :js, :class => "book-link-ajax"
     end
  end
  
  filter :uid 
  filter :title
  filter :isbn
  
end
