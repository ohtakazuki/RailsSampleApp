require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  
  # 編集(edit)の失敗に対するテスト
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    # 無効な値をpatchする
    patch user_path(@user), params: { user: { name: "",
                                      email: "foo@invalid",
                                      password: "foo",
                                      password_confirmation: "bar" } }
    assert_template 'users/edit'
    # 課題：エラーメッセージを含むか
    assert_select "div.alert.alert-danger", text: "The form contains 4 errors."
  end
  
  # 編集(edit)の成功に対するテスト
  test "successful edit" do 
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
  
  # フレンドリーフォワーディングのテスト
  test "successful edit with friendly forwarding" do
    # 編集ページにアクセス
    get edit_user_path(@user)
    # ログインした
    log_in_as(@user)
    # 編集ページにリダイレクトされているか
    assert_redirected_to edit_user_url(@user)
    # 課題(リダイレクト後nilになるはず)
    assert_not session[:forwarding_url] #, edit_user_url(@user)
    
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
  
end
