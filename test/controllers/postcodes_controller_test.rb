require 'test_helper'

class PostcodesControllerTest < ActionController::TestCase
  setup do
    @postcode = postcodes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:postcodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create postcode" do
    assert_difference('Postcode.count') do
      post :create, postcode: { latitude: @postcode.latitude, longitude: @postcode.longitude, name: @postcode.name, postcode: @postcode.postcode }
    end

    assert_redirected_to postcode_path(assigns(:postcode))
  end

  test "should show postcode" do
    get :show, id: @postcode
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @postcode
    assert_response :success
  end

  test "should update postcode" do
    patch :update, id: @postcode, postcode: { latitude: @postcode.latitude, longitude: @postcode.longitude, name: @postcode.name, postcode: @postcode.postcode }
    assert_redirected_to postcode_path(assigns(:postcode))
  end

  test "should destroy postcode" do
    assert_difference('Postcode.count', -1) do
      delete :destroy, id: @postcode
    end

    assert_redirected_to postcodes_path
  end
end
