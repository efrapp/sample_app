require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup" do
    get signup_path
    assert_no_difference 'User.count' do
      post signup_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "123",
                                         password_confirmation: "456" } }
    end

    assert_template 'users/new'
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select "#error_explanation ul li:nth-child(1)", 
                  { text: "Name can't be blank" },
                  "The name can't be blank"
    assert_select "#error_explanation ul li:nth-child(2)",
                  { text: "Email is invalid" }
    assert_select "#error_explanation ul li:nth-child(3)", 
                  { text: "Password confirmation doesn't match Password" }
    
    assert_select "form[action=?]", signup_path
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: { user: { name: 'Efrain Pinto',
                                          email: 'efrain@local.net',
                                          password: '123456',
                                          password_confirmation: '123456' } }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    
    # Invalid activation token
    get edit_account_activation_path("Invalid token", email: user.email)
    assert_not is_logged_in?

    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: "invalid@.d.c")
    assert_not is_logged_in?

    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?

    follow_redirect!
    assert_template 'users/show'

    assert_not flash.empty?
    assert is_logged_in?
  end
end
