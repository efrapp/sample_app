require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:efrain)
  end

  test "unsuccessful edit" do
    log_in_as @user 
    get edit_user_path(@user)
    # assert_redirected_to edit_user_url(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                          email: "efrap@g",
                                          password: "1234",
                                          password_confirmation: "1235" } }
    assert_template 'users/edit'
    assert_select ".alert", { text: "The form contains 4 errors." }
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as @user
    assert_redirected_to edit_user_url(@user)
    name = "Antonio"
    email = "a@p.p"
    patch user_path(@user), params: { user: { name: name,
                                                email: email,
                                                password: "",
                                                password_confirmation: "" }}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end

  test "friendly forwarding happens only the first time" do
    get edit_user_path(@user)
    assert_redirected_to login_url
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
  end
end
