class ApiController < ApplicationController

  STATUS_NOT_APPROVED = 203
  STATUS_NOT_FOUND = 203
  STATUS_APPROVED = 200

  def get_approved_descriptions

    status = STATUS_APPROVED
    books = Book.find_all_by_uid(params[:book_uid])
    book = books[0]

    if book && book.last_approved
      @results = DynamicDescription.connection.select_all("select i.image_location, d.body from dynamic_images i
        left join dynamic_descriptions d on i.id = d.dynamic_image_id where d.book_uid = '#{params[:book_uid]}' and d.is_current = 1")
    else
      @results = Array.new
      @results[0] = "error: not approved"
      status = STATUS_NOT_APPROVED
    end

    respond_to do |format|
      format.xml  { render :xml => @results , :status => status}
      format.json  { render :json => @results, :callback => params[:callback] , :status => status}
    end
  end

  def get_approved_book_stats
    status = STATUS_APPROVED
    books = Book.find_all_by_uid(params[:book_uid])
    book = books[0]

    if book && book.last_approved
      @stats = BookStats.connection.select_all("select bs.book_uid, bs.total_images, bs.total_essential_images,
      bs.total_images_described - bs.essential_images_described as unessential_images_described, bs.essential_images_described, b.last_approved from book_stats bs left join books b on bs.book_uid = b.uid
      where b.uid = '#{params[:book_uid]}'")
    else
      @stats = Array.new

      if book
        @stats[0] = "error: not approved"
        status = STATUS_NOT_APPROVED
      else
        @stats[0] = "error: book not found"
        status = STATUS_NOT_FOUND
      end
    end

    respond_to do |format|
      format.xml  { render :xml => @stats, :status => status }
      format.json  { render :json => @stats, :callback => params[:callback], :status => status }
    end

  end

  def get_approved_stats
    @stats = BookStats.connection.select_all("select bs.book_uid, bs.total_images, bs.total_essential_images,
      bs.total_images_described, b.last_approved from book_stats bs left join books b on bs.book_uid = b.uid
      where b.last_approved > '#{params[:since]}'")
    respond_to do |format|
      format.xml  { render :xml => @stats }
      format.json  { render :json => @stats, :callback => params[:callback] }
    end
  end

end