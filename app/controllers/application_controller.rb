class ApplicationController < ActionController::Base
  # needed to commment out the following to allow cached, transformed html to make authenticated post requests
  #protect_from_forgery
  
  def load_book
    if !params[:book_id].blank?
      Book.find params[:book_id] rescue nil
    elsif !params[:book_uid].blank?
      Book.where(:uid => params[:book_uid]).first
    end
  end
  def authenticate_admin_user!
    authenticate_user!
    redirect_to '/' unless current_admin_user
  end
  
  def current_admin_user
    current_user if can? :view_admin, @all
  end
end
