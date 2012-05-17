class EditBookController < ApplicationController
  before_filter :authenticate_user!
  include RepositoryChooser

  def initialize
    super()
    @repository = RepositoryChooser.choose
  end

  FILTER_ALL = 0
  FILTER_ESSENTIAL = 1
  FILTER_NON_ESSENTIAL = 2
  FILTER_DESCRIPTION_NEEDED = 3
  FILTER_UNSPECIFIED = 4

  # just to help determine page size limits
  def edit_side_bar_only
    edit
  end

  # just to help determine page size limits
  def edit_content_only
    edit
  end

  def edit
    error_redirect = 'edit_book/describe'
    book_id = params[:book_id]
    book_uid = params[:book_uid]
    
    if (book_uid)
      book = Book.where(:uid => book_uid, :library_id => current_library.id).first
      book_id = session[:book_id] = book.id.to_s if book
    elsif (book_id)
      session[:book_id] = book_id.strip
    else
      book_id = session[:book_id]
    end

    if(!book_id || book_id.length == 0)
      if (:book_uid && book_uid.length > 0 )
         flash.now[:alert] = "That book isn't in your library"
         render :template => error_redirect
         return
      end
      flash.now[:alert] = "Must specify a book ID"
      #redirect_to :action => 'index'
      render :template => error_redirect
      return
    end

    @book = Book.where(:id => book_id, :library_id => current_library.id).first
    if(!@book)
      flash[:alert] = "There is no book in the system with that ID (#{book_id}) ."
      render :template => error_redirect
      return
    end

    if(@book.status == 0)
      flash[:alert] = "That book (#{@book.uid}) needs to be re-uploaded as its files have expired."
      render :template => error_redirect
      return
    end

    if(@book.status != 3)
      flash[:alert] = "That book (#{@book.uid}) is still being processed. Please try again later."
      render :template => error_redirect
      return
    end
    render :layout => 'frames'
  end
  
  def book_header
    render :layout => 'simple_layout'
  end

  def content
    book_fragment_id = params[:book_fragment_id] || session[:book_fragment_id]
    unless book_fragment_id
      book_id = params[:book_id] || session[:book_id]
      @book = Book.where(:id => book_id, :library_id => current_library.id).first
      if @book
        book_fragment = @book.book_fragments.first
        book_fragment_id = book_fragment.id if book_fragment
      end
    end
    
    @book_fragment = BookFragment.joins(:book).where(:id => book_fragment_id, :books => {:library_id => current_library.id}).first
    if @book_fragment
      @book = @book_fragment.book
    
      session[:book_id] = book_id
      @host = @repository.get_host(request)
      html = if @book
        book_uid = @book.uid
        file_name = "#{book_uid}_#{@book_fragment.sequence_number}.html"
        @repository.get_cached_html(book_uid, file_name)
      end
    end
    if (@book_fragment && html)
      render :layout => 'content_layout', :text => html, :content_type => 'text/html'
    else
      logger.warn "could not find cached html for book id, #{book_id}"
      render :status => 404
    end
  end

  def side_bar
    book_id = params[:book_id] || session[:book_id]
    session[:book_id] = book_id
    @book = Book.where(:id => book_id, :library_id => current_library.id).first
    
    if @book
      filter = params[:filter]
      @filter = filter
      @host = @repository.get_host(request)
      case filter.to_i
        when FILTER_ALL
          @images = DynamicImage.where(:book_id => @book.id, :book_fragment_id => params[:book_fragment_id]).order("id ASC")
        when FILTER_ESSENTIAL
          @images = DynamicImage.where(:book_id => @book.id, :book_fragment_id => params[:book_fragment_id], :should_be_described => true).order("id ASC")
        when FILTER_NON_ESSENTIAL
          @images = DynamicImage.where(:book_id => @book.id, :book_fragment_id => params[:book_fragment_id], :should_be_described => false).order("id ASC")
        when FILTER_DESCRIPTION_NEEDED
          # ESH: used to be:::
          # @images = DynamicImage.find_by_sql("SELECT * FROM dynamic_images WHERE book_uid = '#{book_uid}' and should_be_described = true and id not in (select dynamic_image_id from dynamic_descriptions where dynamic_descriptions.book_uid = '#{book_uid}') ORDER BY id ASC;")
          @images = DynamicImage.includes(:dynamic_descriptions).where(:book_id => @book.id, :book_fragment_id => params[:book_fragment_id], :should_be_described => true, :dynamic_descriptions => {:id => nil}).order('dynamic_images.id asc')
        when FILTER_UNSPECIFIED
          @images = DynamicImage.where(:book_id => @book.id, :book_fragment_id => params[:book_fragment_id], :should_be_described => nil).order("id ASC")
        else
          @filter = "0"
          @images = DynamicImage.where(:book_id => @book.id, :book_fragment_id => params[:book_fragment_id]).order("id ASC")
      end
    end
    render :layout => 'nav_bar'
  end

  def top_bar
  end

  def describe
  end

 def help
 end
 
 def description_guidance
   render :layout =>'guidelines_layout'
 end

end