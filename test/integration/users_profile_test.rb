require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  # fill_title ヘルパー利用用
  include ApplicationHelper
  
  def setup
    @user = users(:michael)
  end
  
  # プロフィール画面にアクセスしたとき正しく表示されること
  test "profile display" do
    # プロフィール画面にアクセス
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name) 
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    # マイクロポストの投稿数(response.body=ページのHTML)
    assert_match @user.microposts.count.to_s, response.body
    # ページ分割
    assert_select 'div.pagination'
    # コンテンツが存在するか
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
