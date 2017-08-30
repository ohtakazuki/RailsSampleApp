require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # ----------------------------------------
  # 無効なユーザ登録に対するテスト
  test "invalid signup information" do
    # signupページを取得する
    get signup_path

    # post先をsignup_pathにしたことによるテスト    
    assert_select 'form[action="/signup"]'

    # doの中の処理の実行前後でUser.countが変わらない
    assert_no_difference 'User.count' do
      # postのシミュレート
      # routesに post '/signup', to:'users#create' を追加したことで
      # 以下は signup_path でも成功する
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    # エラーなのでnewテンプレートに戻るはず
    # controllerで render newしてる
    assert_template 'users/new'

    # エラーメッセージに対するテスト
    assert_select 'div#error_explanation'
    assert_select 'div.alert.alert-danger'
  end

  # ----------------------------------------
  # 有効なユーザ登録に対するテスト
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty? # flashの存在確認
    assert is_logged_in?    # ログイン済か
  end  

end
