class ApiController < ApplicationController

  STATUS_NOT_APPROVED = 203
  STATUS_NOT_FOUND = 203
  STATUS_APPROVED = 200

  def get_approved_descriptions_and_book_stats
    book_stats_from_uid(params[:book_uid]) do |book|
      images_and_descriptions = book.current_images_and_descriptions.all
      stats = strip_attributes(book.book_stats_plus_unessential_images_described.all)
      {:stats => stats, :images_and_descriptions => images_and_descriptions}
    end
  end

  def get_approved_descriptions
    book_stats_from_uid(params[:book_uid]) do |book|
      images_and_descriptions = book.current_images_and_descriptions.all
      {:images_and_descriptions => images_and_descriptions}
    end
  end

  def get_approved_book_stats
    book_stats_from_uid(params[:book_uid]) do |book|
      stats = strip_attributes(book.book_stats_plus_unessential_images_described.all)
      {:stats => stats}
    end
  end

  def get_approved_stats
    @stats = BookStats.connection.select_all("select bs.book_id, bs.total_images, bs.total_essential_images,
      bs.total_images_described, b.last_approved from book_stats bs left join books b on bs.book_id = b.id
      where b.last_approved > '#{params[:since]}'")
    respond_to do |format|
      format.xml  { render :xml => @results }
      format.json  { render :json => @results, :callback => params[:callback] }
    end
  end
  
  protected
  # to_xml has problems if a nil generated field is added to the select; for example Book#book_stats_plus_unessential_images_described has total_images_described - essential_images_described as unessential_images_described.  If you extract the attributes object things are happier
  def strip_attributes models
    models.map{|model| model.attributes}
  end
  # Load up a book based on a UID.  If found, call a block to process it and return the results in XML or JSON
  def book_stats_from_uid book_uid
    @status = STATUS_APPROVED
    @book = Book.where(:uid => book_uid).first

    if @book && @book.last_approved
      @results = yield @book
    else
      @results = []
      if @book
        @results << "error: not approved"
        @status = STATUS_NOT_APPROVED
      else
        @results << "error: book not found"
        @status = STATUS_NOT_FOUND
      end
    end
    
    respond_to do |format|
      @results ||= {}
      format.xml  { render :xml => {:book => @book, :status => @status}.merge(@results) }
      format.json  { render :json => {:book => @book, :callback => params[:callback], :status => @status}.merge(@results) }
    end
  end
end