require 'spec_helper'

describe UsersController do
 login_user

 before(:each) do
  @user = Factory(:user)
  @role = Factory(:role)
  @user_role = Factory(:user_role)
 end 
 
 describe "GET index" do
   it "should be successful" do
     get :index, :user_id => @user.id
     response.should be_success
   end
 end
 
 describe "PUT update" do
  
  describe "with valid params" do
   it "updates the user" do
    new_username = 'my_user_name'
    put :update, :id => @user.id, :user => {:username => new_username}
    assigns(:user).should eq (@user)
    @user.reload.username.should eq new_username
   end
  end
  
  describe "roles outside the admin tool" do
    it "updates the user" do  
     lambda { put(:update, :id => @user.id, :user => {:role_ids => [@user_role]})}.should raise_error(Exception, "Unathorized access - Assigning roles outside of the admin tool")
    end
   end
 end
 
end