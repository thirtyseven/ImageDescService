class ApiController < ApplicationController

  STATUS_NOT_APPROVED = 203
  STATUS_NOT_FOUND = 203
  STATUS_APPROVED = 200
  
  def get_approved_descriptions_and_book_states
    # TODO ESH: return a combination of get_approved_descriptions and get_approved_book_stats
  end

  def get_approved_descriptions

    status = STATUS_APPROVED
    book = Book.where(:uid => params[:book_uid]).first

    if book && book.last_approved
      @results = book.current_images_and_descriptions.all
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
    book = Book.where(:uid => params[:book_uid]).first

    if book && book.last_approved
      @stats = book.book_stats
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
      format.xml  { render :xml => {:stats => @stats, :book => book}, :status => status }
      format.json  { render :json => {:stats => @stats, :book => book}, :callback => params[:callback], :status => status }
    end

  end

  def get_approved_stats
    @stats = BookStats.connection.select_all("select bs.book_id, bs.total_images, bs.total_essential_images,
      bs.total_images_described, b.last_approved from book_stats bs left join books b on bs.book_id = b.id
      where b.last_approved > '#{params[:since]}'")
    respond_to do |format|
      format.xml  { render :xml => @stats }
      format.json  { render :json => @stats, :callback => params[:callback] }
    end
  end

end