require 'test_helper'

class LayoutLinksTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:efrain)
  end

  test "logged in users should have log in links" do
    log_in_as(@user)
    get root_url
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", login_path, count: 0
  end

  test "non-logged in users shouldn't have log in links" do
    get root_url
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
    assert_select "a[href=?]", edit_user_path(@user), count: 0
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", login_path
  end
end
