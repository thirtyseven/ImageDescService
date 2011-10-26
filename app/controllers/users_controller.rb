class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    #@users = User.all
    @users = User.find(:all, :order => "created_at")
  end
end