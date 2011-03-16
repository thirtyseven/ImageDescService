require 'test_helper'

class DynamicDescriptionsControllerTest < ActionController::TestCase
  setup do
    @dynamic_description = dynamic_descriptions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dynamic_descriptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dynamic_description" do
    assert_difference('DynamicDescription.count') do
      post :create, :dynamic_description => @dynamic_description.attributes, :uid => 'book01', :image_location => 'img03.jpg'
    end

    assert_redirected_to dynamic_description_path(assigns(:dynamic_description))
  end

  test "missing parameters on json create" do
    post :create, :dynamic_description => @dynamic_description.attributes, :format => 'json'
    assert_response :non_authoritative_information
  end

  test "should get edit" do
    get :edit, :id => @dynamic_description.to_param
    assert_response :success
  end

  test "should destroy dynamic_description" do
    assert_difference('DynamicDescription.count', -1) do
      delete :destroy, :id => @dynamic_description.to_param
    end

    assert_redirected_to dynamic_descriptions_path
  end
end
