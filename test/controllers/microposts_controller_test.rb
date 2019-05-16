require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @micropost = microposts(:orange)
  end

  test "non-logged in user shouldn't create microposts" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { 
                                      content: 'First micropost'
                                    } }
    end
    assert_redirected_to login_url
  end

  test "non-logged in user shouldn't destroy microposts" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  test "one user shouldn't delete the micropost of other user" do
    log_in_as(users(:efrain))
    micropost = microposts(:ants)
    assert_no_difference "Micropost.count" do
      delete micropost_path(micropost)
    end

    assert_redirected_to root_url
  end
end
