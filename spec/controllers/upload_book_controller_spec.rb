require 'spec_helper'

describe UploadBookController do
  include DelayedJobSpecHelper

=begin
  describe 'should upload book' do
    it "should be successful" do
      post 'submit', :book => 'features/fixtures/DaisyZipBookUnencrypted.zip'
      work_off
      response.should be_success
    end
  end
=end



end