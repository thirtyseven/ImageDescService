require 'test_helper'

class DynamicImagesControllerTest < ActionController::TestCase
  setup do
    @dynamic_image = dynamic_images(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dynamic_images)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dynamic_image" do
    assert_difference('DynamicImage.count') do
      post :create, :dynamic_image => @dynamic_image.attributes
    end

    assert_redirected_to dynamic_image_path(assigns(:dynamic_image))
  end

  test "should show description" do
    get :show, :uid => 'book01', :image_location => 'img03.jpg'
    assert_response :success
  end

  test "non-existent image on json show description" do
    get :show, :uid =>'blah', :image_location => 'blah', :format => 'json'
    assert_response :no_content
  end

  test "missing parameters on json show description" do
    get :show, :uid =>'blah', :format => 'json'
    assert_response :non_authoritative_information
  end

  test "should get edit" do
    get :edit, :id => @dynamic_image.to_param
    assert_response :success
  end

end
