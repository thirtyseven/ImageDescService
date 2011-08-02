require 'test_helper'

class DaisyBookControllerTest < ActionController::TestCase

  test "Daisy without DTD is considered valid" do
    controller = DaisyBookController.new
    assert_true controller.valid_daisy_zip?("features/fixtures/DaisyZipBookUnencrypted.zip")

    Zip::Archive.encrypt("features/fixtures/EncryptedDaisy.zip", "new_password")
    assert_raise(Zip::Error) {Zip::Archive.decrypt("features/fixtures/EncryptedDaisy.zip", "bad_password") }
    assert_nothing_raised(Zip::Error) {Zip::Archive.decrypt("features/fixtures/EncryptedDaisy.zip", "new_password") }
  end
end
