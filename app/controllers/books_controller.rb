class BooksController < ApplicationController
  before_filter :authenticate_user!

  # GET /books
  # GET /books.xml
  def index

    #@books = Book.all
    @books = Book.page(params[:page]).order('title ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @books }
    end
  end

  def mark_approved
    books = Book.find_all_by_uid(params[:book_id])
    book = books[0]
    book.mark_approved

    render :text=>"approved",  :content_type => 'text/plain'
  end

end