require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:efrain)
  end

  test "login user" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: 'e@p.p', password: '123' } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                           password: 'password' } }
    assert is_logged_in?
    # to check if the redirect was to the right target
    assert_redirected_to @user
    # to visit the target page, in this case users show
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    
    # Logout steps
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second browser
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", user_path(@user), count: 0
    assert_select "a[href=?]", logout_path, count: 0
  end

  test "remember me option is active" do
    log_in_as(@user, remember_me: '1')
    # Old way
    # assert !cookies[:remember_token].nil?
    # Minitest way
    assert_not_empty cookies[:remember_token]
    assert_equal cookies[:remember_token], assigns(:user).remember_token
  end

  # This test is made with two logins because if we just test
  # with remember me option unchecked we aren't properly checking
  # the cookie had a value and now it isn't since this is the
  # default value of the cookie
  test "remember me option is disable" do
    # Login first time to to set the cookie
    log_in_as(@user, remember_me: '1')
    # Login second time unchecking the box to make sure
    # the cookied was deleted
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
end
