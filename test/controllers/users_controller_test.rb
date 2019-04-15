require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:efrain)
    @other_user = users(:mafe)
  end

  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "non-logged-in users can't access edit form" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "non-logged-in users can't access update action" do
    patch user_path(@user), params: { user: { name: "Efrain",
                                               email: "e@g.c",
                                               password: "",
                                               password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as @other_user
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email,
                                              password: "",
                                              password_confirmation: "" } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "shoud redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "admin attribute shoudn't be updated from web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@user), params: { user: { name: 'Efrain',
                                              email: 'e@p.p',
                                              password: '123456',
                                              password_confirmation: '123456',
                                              admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "non-logged-in users shouldn't destroy other users" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "logged-in users but not admin shouldn't destroy other users" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@other_user)
    end
    assert_redirected_to root_url
  end

end
