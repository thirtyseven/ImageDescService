require 'spec_helper'

describe DaisyBookController do

  describe "GET 'upload'" do
    it "should be successful" do
      get 'upload'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end

end
