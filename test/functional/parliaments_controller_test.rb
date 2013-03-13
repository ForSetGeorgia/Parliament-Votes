require 'test_helper'

class ParliamentsControllerTest < ActionController::TestCase
  setup do
    @parliament = parliaments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:parliaments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create parliament" do
    assert_difference('Parliament.count') do
      post :create, parliament: @parliament.attributes
    end

    assert_redirected_to parliament_path(assigns(:parliament))
  end

  test "should show parliament" do
    get :show, id: @parliament.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @parliament.to_param
    assert_response :success
  end

  test "should update parliament" do
    put :update, id: @parliament.to_param, parliament: @parliament.attributes
    assert_redirected_to parliament_path(assigns(:parliament))
  end

  test "should destroy parliament" do
    assert_difference('Parliament.count', -1) do
      delete :destroy, id: @parliament.to_param
    end

    assert_redirected_to parliaments_path
  end
end
