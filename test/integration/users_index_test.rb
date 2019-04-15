require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:efrain)
    @non_admin = users(:mafe)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |u|
      assert_select "a[href=?]", user_path(u), text: u.name
      unless u == @user
        assert_select "a[href=?]", user_path(u), text: 'Delete'
      end
    end
  end

  test "non-admin users shouldn't see the delete link" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "admin user should delete another users" do
    log_in_as(@user)
    assert_difference 'User.count', -1 do
      delete user_path(@user)
    end
  end
end
