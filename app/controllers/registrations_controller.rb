class RegistrationsController < Devise::RegistrationsController
  def new
    Exception.new "Unathorized access - Assigning roles outside of the admin tool" if params[:user] && params[:user][:role_ids]
    super
  end

  def create
    Exception.new "Unathorized access - Assigning roles outside of the admin tool" if params[:user] && params[:user][:role_ids]
    super
  end

  def update
    Exception.new "Unathorized access - Assigning roles outside of the admin tool" if params[:user] && params[:user][:role_ids]
    super
  end
end 
