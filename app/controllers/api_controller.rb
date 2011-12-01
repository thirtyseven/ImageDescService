class ApiController < ApplicationController

  def get_books_with_images
    @books = Book.find_by_sql("select uid, title from books where uid in (select distinct(book_uid) from dynamic_descriptions)")

    respond_to do |format|
      format.xml  { render :xml => @books }
      format.json  { render :json => @books, :callback => params[:callback] }
    end
  end

  def get_latest_descriptions

    books = Book.find_all_by_uid(params[:book_uid])
    book = books[0]


    if book && book.last_approved
      @results = DynamicDescription.connection.select_all("select i.image_location, d.body from dynamic_images i, (select d1.body, d1.dynamic_image_id
        from dynamic_descriptions d1
        left join dynamic_descriptions d2
           on d1.book_uid = d2.book_uid
           and d1.dynamic_image_id = d2.dynamic_image_id
           and d1.created_at < d2.created_at
        where d1.book_uid = '#{params[:book_uid]}'
        and d2.created_at is null) as d
        where i.id = d.dynamic_image_id")



    else
      @results = Array.new
      @results[0] = "error: not approved"
    end

    respond_to do |format|
      format.xml  { render :xml => @results }
      format.json  { render :json => @results, :callback => params[:callback] }
    end
  end

  def get_approved_book_stats
    @stats = BookStats.connection.select_all("select bs.book_uid, bs.total_images, bs.total_essential_images,
      bs.total_images_described, b.last_approved from book_stats bs left join books b on bs.book_uid = b.uid
      where b.last_approved > '#{params[:since]}'")
    respond_to do |format|
      format.xml  { render :xml => @stats }
      format.json  { render :json => @stats, :callback => params[:callback] }
    end
  end

end