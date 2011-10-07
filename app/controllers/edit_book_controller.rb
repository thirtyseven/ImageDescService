class EditBookController < ApplicationController
  before_filter :authenticate_user!
  include S3Repository

  FILTER_ALL = 0
  FILTER_ESSENTIAL = 1
  FILTER_NON_ESSENTIAL = 2
  FILTER_DESCRIPTION_NEEDED = 3
  FILTER_UNSPECIFIED = 4

  def edit
    return_to = params[:return_to]
    error_redirect = 'edit_book/describe'

    book_uid = params[:book_uid].strip
    if (book_uid)
      session[:book_uid] = book_uid
    else
      book_uid = session[:book_uid]
    end

    if(!book_uid || book_uid.length == 0)
      flash[:alert] = "Must specify a book ID"
      #redirect_to :action => 'index'
      render :template => error_redirect
      return
    end

    book = Book.find_by_uid(book_uid)
    if(!book)
      flash[:alert] = "There is no book in the system with that ID (#{book_uid}) ."
      render :template => error_redirect
      return
    end

    if(book.status = 0)
      flash[:alert] = "That book (#{book_uid}) needs to be re-uploaded as its files have expired."
      render :template => error_redirect
      return
    end

    if(book.status != 3)
      flash[:alert] = "That book (#{book_uid}) is still being processed. Please try again later."
      render :template => error_redirect
      return
    end

    render :layout => 'frames'
  end

  def content
    book_uid = session[:book_uid]

    file_name = book_uid + ".html"
    html = get_cached_html(book_uid, file_name)
    if (html)
      render :text => html, :content_type => 'text/html'
    else

=begin
      book = Book.find_by_uid(book_uid)
      xml_filename = book.xml_file
      xml = get_xml_from_s3(book_uid, xml_filename)
      xsl_filename = 'app/views/xslt/daisyTransform.xsl'
      xsl = File.read(xsl_filename)
      contents = xslt(xml, xsl, request.host_with_port)
      render :text => contents, :content_type => 'text/html'
=end

      logger.warn "could not find cached html for book uid, #{book_uid}"
      render :status => 404
    end
  end

  def side_bar
    book_uid = session[:book_uid]
    if (!book_uid)
      book_uid = params[:book_uid]
      session[:book_uid] = book_uid
    end
    filter = params[:filter]
    @filter = filter
    @host = "//s3.amazonaws.com/" + ENV['POET_ASSET_BUCKET']
    if (ENV['POET_LOCAL_STORAGE_DIR'])
      @host = "//" + request.host_with_port + "/daisy_book/book"
    end
    case filter.to_i
      when FILTER_ALL
        @images = DynamicImage.where(:book_uid => book_uid).order("id ASC")
      when FILTER_ESSENTIAL
        @images = DynamicImage.where(:book_uid => book_uid, :should_be_described => true).order("id ASC")
      when FILTER_NON_ESSENTIAL
        @images = DynamicImage.where(:book_uid => book_uid, :should_be_described => false).order("id ASC")
      when FILTER_DESCRIPTION_NEEDED
        @images = DynamicImage.find_by_sql("SELECT * FROM dynamic_images WHERE book_uid = '#{book_uid}' and should_be_described = true and id not in (select dynamic_image_id from dynamic_descriptions where dynamic_descriptions.book_uid = '#{book_uid}') ORDER BY id ASC;")
      when FILTER_UNSPECIFIED
        @images = DynamicImage.where(:book_uid => book_uid, :should_be_described => nil).order("id ASC")
      else
        @filter = "0"
        @images = DynamicImage.where(:book_uid => book_uid).order("id ASC")
    end

    render :layout => 'nav_bar'
  end

  def top_bar
    return
  end

  def describe
    return
  end

end