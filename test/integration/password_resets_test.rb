require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    @existing_user = users(:mafe)
  end

  test "reset password with invalid email should redirect forgot password form" do
    # get password reset form
    get new_password_reset_path
    assert_template 'password_resets/new'
    # send email to get reset link
    post password_resets_path,
         params: { password_reset: { email: 'non@existing.com' } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  test "reset password with valid email should send reset link" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    post password_resets_path,
         params: { password_reset: { email: @existing_user.email } }
    assert_not_equal @existing_user.reset_digest,
                     @existing_user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_path

    # @controller.action_name allowed me to understand that all the testing
    # is happening in the action so assertions like assert_redirected_to
    # doesn't go literally to the path specified, it is just testing that it
    # will go to that path.
    # 
    # In the case of the assigns(:user) we are using the instance variable
    # @user created in the PasswordResets controllers' create action to get
    # access to the reset_token virtual field
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # Empty password
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_nil user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    # generate reset link
    get new_password_reset_path
    post password_resets_path, 
         params: { password_reset: { email: @existing_user.email } }
    user = assigns(:user)
    user.update_attribute(:reset_sent_at, 3.hours.ago)
    # go to reset form and try to change password with an expired link
    patch password_reset_path(user.reset_token), 
          params: { email: user.email,
                    user: { password: '123456',
                            passowrd_confirmation: '123456' } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
