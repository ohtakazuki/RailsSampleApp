require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # 以下は慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end
  
  # 正常系
  test "should be valid" do
    assert @micropost.valid?
  end
  
  # useridが存在すること
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  # contentが存在すること
  test "content should be present" do
    @micropost.content = "  "
    assert_not @micropost.valid?
  end
  
  # contentが140文字以内であること
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
  
  # マイクロポストの並び順
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
