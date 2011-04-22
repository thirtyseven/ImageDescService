class UpdateDescriptionsInBookController < ApplicationController
  def upload
    book = params[:book]
    render :text => book.read
  end
end
