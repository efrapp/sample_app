require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:efrain)
    # Idimatically incorrect way to create a micropost
    # @micropost = Micropost.new(content: 'Lorem ipsum', user_id: @user.id)

    # This way is the correct way because use the association between models
    @micropost = @user.microposts.build(content: 'Lorem ipsum')
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "micropost content should be present" do
    @micropost.content = " "
    assert_not @micropost.valid?
  end

  test "content should 140 characters long" do
    @micropost.content = "c" * 141
    assert_not @micropost.valid?
  end

  test "most recent micropost appears first" do
    micropost = microposts(:most_recent)
    assert_equal micropost, Micropost.first
  end
end
