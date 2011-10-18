class BooksController < ApplicationController

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

  def get_books_with_images
    @books = Book.find_by_sql("select uid, title from books where uid in (select distinct(book_uid) from dynamic_descriptions)")

    respond_to do |format|
      format.xml  { render :xml => @books }
      format.json  { render :json => @books, :callback => params[:callback] }
    end
  end

  def get_latest_descriptions

    #@descriptions = DynamicImage.find_by_sql("select i.image_location from dynamic_images i where book_uid = '#{params[:book_uid]}'")
    #@descriptions = DynamicDescription.connection.select_all("select d.body, max(d.updated_at) date, i.image_location from dynamic_descriptions d, dynamic_images i where d.book_uid = '#{params[:book_uid]}' and i.id = d.dynamic_image_id group by d.dynamic_image_id ")
    @descriptions = DynamicDescription.connection.select_all("select i.image_location, d.body from dynamic_images i, (select d1.body, d1.dynamic_image_id
      from dynamic_descriptions d1
      left join dynamic_descriptions d2
         on d1.book_uid = d2.book_uid
         and d1.dynamic_image_id = d2.dynamic_image_id
         and d1.created_at < d2.created_at
      where d1.book_uid = '#{params[:book_uid]}'
      and d2.created_at is null) as d
      where i.id = d.dynamic_image_id")
    respond_to do |format|
      format.xml  { render :xml => @descriptions }
      format.json  { render :json => @descriptions, :callback => params[:callback] }
    end

  end

end