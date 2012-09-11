class BooksController < ApplicationController
  before_filter :authenticate_user!

  # GET /books
  # GET /books.xml
  def index
    #@books = Book.all
    @books = Book.where(:library_id => current_library.id).where("status <> 4").page(params[:page]).order('title ASC')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @books }
    end
  end

  def mark_approved
    book = Book.find params[:book_id] rescue nil
    book.mark_approved

    render :text=>"approved",  :content_type => 'text/plain'
  end
  

  def book_list
    @books = Book.where(:library_id => current_library.id).where(" status <> 4 ").page(params[:page]).order('title ASC')
  end
  
  def book_list_by_user 
    @books =  Book.where(:user_id => current_user.id).where(" status <> 4 ")  
  end
  
  def delete
    @book = Book.find(params[:book_id])
    @book.destroy
    if params[:nav] == 'myBooks'
      redirect_to book_list_by_user_path
    else
      redirect_to admin_books_path
    end
  end
end