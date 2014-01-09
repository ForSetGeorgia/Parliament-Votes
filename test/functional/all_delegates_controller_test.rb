require 'test_helper'

class AllDelegatesControllerTest < ActionController::TestCase
  setup do
    @all_delegate = all_delegates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:all_delegates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create all_delegate" do
    assert_difference('AllDelegate.count') do
      post :create, all_delegate: @all_delegate.attributes
    end

    assert_redirected_to all_delegate_path(assigns(:all_delegate))
  end

  test "should show all_delegate" do
    get :show, id: @all_delegate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @all_delegate.to_param
    assert_response :success
  end

  test "should update all_delegate" do
    put :update, id: @all_delegate.to_param, all_delegate: @all_delegate.attributes
    assert_redirected_to all_delegate_path(assigns(:all_delegate))
  end

  test "should destroy all_delegate" do
    assert_difference('AllDelegate.count', -1) do
      delete :destroy, id: @all_delegate.to_param
    end

    assert_redirected_to all_delegates_path
  end
end
