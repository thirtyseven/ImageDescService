class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @users = User.find(:all, :order => "created_at")
  end
  
  
  def edit
    @user= current_user #TODO check can can priviledges to let user edit other user
  end

  def update
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


end