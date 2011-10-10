require 'spec_helper'

describe DaisyBookController do

  describe "GET 'process'" do
    it "should be successful" do
      get 'process'
      response.should be_success
    end
  end


end
