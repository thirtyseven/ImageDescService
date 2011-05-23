class DaisyBookController < ApplicationController
  def upload
  end

  def edit
    book = params[:book]
    if !book
      flash[:alert] = "Must specify a book file to process"
      redirect_to :action => 'upload'
      return
    end
  end

end
