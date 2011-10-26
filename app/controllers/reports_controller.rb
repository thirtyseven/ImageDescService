class ReportsController < ApplicationController
  before_filter :authenticate_user!
  include ActionView::Helpers::NumberHelper

  def index

    @books_total = Book.connection.select_value("select count(uid) from books where uid in (select distinct(book_uid) from dynamic_descriptions)")
    @descriptions_total = DynamicDescription.connection.select_value("select count(id) from dynamic_descriptions")
    @images_described = DynamicDescription.connection.select_value("select count(distinct(dynamic_image_id)) from dynamic_descriptions")

    @book_stats = BookStats.find(:all, :order => "book_title")


  end

  def view_book

    book_uid = params[:book_uid]

    if(!book_uid || book_uid.length == 0)
      flash[:alert] = "Must specify a book ID"
      redirect_to :action => 'index'
      return
    end

    @book = Book.find_by_uid(book_uid.strip)
    if(!@book)
      flash[:alert] = "There is no book in the system with that ID (#{book_uid}) ."
      redirect_to :action => 'index'
      return
    end

    @descriptions_total = DynamicDescription.connection.select_value("select count(id) from dynamic_descriptions where book_uid = '#{book_uid}'")
    @images_described = DynamicDescription.connection.select_value("select count(distinct(dynamic_image_id)) from dynamic_descriptions where book_uid = '#{book_uid}'")
    @images_total = DynamicImage.connection.select_value("select count(id) from dynamic_images where book_uid = '#{book_uid}'")
    @description_still_needed  = DynamicImage.connection.select_value("SELECT count(id) FROM dynamic_images WHERE book_uid = '#{book_uid}' and should_be_described = true and id not in (select dynamic_image_id from dynamic_descriptions where dynamic_descriptions.book_uid = '#{book_uid}') ORDER BY id ASC;")
    @essential_images_total = DynamicImage.connection.select_value("select count(id) from dynamic_images where book_uid = '#{book_uid}' and should_be_described = #{EditBookController::FILTER_ESSENTIAL}")

  end

  def update_book_stats
    Book.find_each do |book|
      BookStats.create_book_row(book)
    end

    redirect_to :action => :index
=begin
    index
    render :action => "reports/index"
=end
  end

  def report_all
    ## total images by book
    ## select book_uid, count(book_uid) from dynamic_images group by book_uid;

    ## essential images by book
    ## select book_uid, count(book_uid) from dynamic_images where should_be_described = true group by book_uid;

    ## described images by book
    ## select book_uid, count(distinct(dynamic_image_id)) from dynamic_descriptions group by book_uid;
  end

end