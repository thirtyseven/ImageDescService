require 'spec_helper'

describe DynamicDescriptionsController do

  before (:each) do
    @user = Factory(:user)
    sign_in @user
  end

  describe "should get new" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "should get index" do
    it "should be successful" do
      get 'index'
      response.should be_success
      assert_not_nil assigns(:dynamic_descriptions)
    end
  end


end