require 'test_helper'

class DaisyBookControllerTest < ActionController::TestCase

  test "Daisy without DTD is considered valid" do
    controller = DaisyBookController.new
    assert_true controller.valid_daisy_zip?("features/fixtures/DaisyZipBookUnencrypted.zip")
  end
end
