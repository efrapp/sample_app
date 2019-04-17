require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest
  test "non-activated user shouldn't be showed" do
    post signup_path, params: { user: { name: 'User',
                                        email: 'u@u.c',
                                        password: '123456',
                                        passoword_confirmation: '123456' } }
    user = assigns(:user)
    assert_redirected_to root_url

    # Try to get the profile page of the non-activated user
    get user_path(user)
    assert_redirected_to root_url
    assert_not flash.empty?
  end
end
