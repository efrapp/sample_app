require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:efrain)
  end

  test "login user" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { sessions: { email: 'e@p.p', password: '123' } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "successful login" do
    get login_path
    post login_path, params: { sessions: { email: @user.email,
                                           password: 'password' } }
    assert is_logged_in?
    # to check if the redirect was to the right target
    assert_redirected_to @user
    # to visit the targe page, in this case users show
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "log_out" do
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", user_path(@user), count: 0
    assert_select "a[href=?]", logout_path, count: 0
  end
end
