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
  
end
