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

  test "should show dynamic_image" do
    get :show, :id => @dynamic_image.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @dynamic_image.to_param
    assert_response :success
  end

  test "should update dynamic_image" do
    put :update, :id => @dynamic_image.to_param, :dynamic_image => @dynamic_image.attributes
    assert_redirected_to dynamic_image_path(assigns(:dynamic_image))
  end

  test "should destroy dynamic_image" do
    assert_difference('DynamicImage.count', -1) do
      delete :destroy, :id => @dynamic_image.to_param
    end

    assert_redirected_to dynamic_images_path
  end
end
