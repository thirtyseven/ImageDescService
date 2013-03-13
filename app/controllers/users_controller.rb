class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => :terms_of_service
  def index
    @users = User.find(:all, :order => "created_at")
  end
  
  
  def edit
    @user= current_user #TODO check can can priviledges to let user edit other user
  end

  def update
    Exception.new "Unathorized access - Assigning roles outside of the admin tool" if params[:user] && params[:user][:role_ids]
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user]) && (@user.id == current_user.id)
        format.html { redirect_to  '/'  }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def terms_of_service
  end

end