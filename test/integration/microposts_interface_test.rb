require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:efrain)
  end

  test "micropost interface" do
    # log in first
    log_in_as(@user)
    assert is_logged_in?
    # check pagination on user profile page
    get user_path(@user)
    assert_template 'users/show'
    assert_select '.pagination'
    # check pagination on home page
    get root_path
    assert_select '.pagination'
    assert_select 'input[type=file]'
    # try to create an invalid micropost
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: " " } }
    end
    assert_template 'static_pages/home'
    assert_select 'div#error_explanation'
    # create a valid micropost
    content = "valid post"
    picture = fixture_file_upload('test/fixtures/files/rails.png', 'image/png')
    p picture
    assert_difference "Micropost.count", 1 do
      post microposts_path params: { micropost: { content: content,
                                                  picture: picture } }
    end
    # assert assigns(:micropost).picture? # this test doesn't work
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # delete a post
      # In my logic I chose a fixture from the microposts tha it was related
      # to @user
      # micropost = microposts(:orange)
    
      #but it is better to make the query (Rails tutorial logic)
      micropost = @user.microposts.paginate(page: 1).first 
    assert_difference "Micropost.count", -1 do
      delete micropost_path(micropost)
    end
    # In the tutorial this not was tested
    # assert_redirected_to request.referrer

    # Check delete link on other user
    other_user = users(:mafe)
    get user_url(other_user)
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_url
    assert_match "#{@user.microposts.count} microposts", response.body
    # with zero microposts
    other_user = users(:malory)
    log_in_as(other_user)
    get root_url
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "My first post")
    get root_url
    assert_match "1 micropost", response.body
  end
end
