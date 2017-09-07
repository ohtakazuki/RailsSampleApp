require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  # ログイン（エラー）
  test "login with invalid information" do
    # ログインページの取得
    get login_path
    assert_template 'sessions/new'  # ログイン画面が表示される

    # emailとpassをポスト
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'  # エラーなのでログイン画面に戻る
    assert_not flash.empty?         # flashも表示されている

    # 他のページに遷移
    get root_path
    assert flash.empty?  # flashは空のはず
  end
  
  # ログイン（正常系）
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    
    # ログイン済か？
    assert is_logged_in?
    
    # user_urlにリダイレクトするか
    assert_redirected_to @user
    follow_redirect!
    
    # リダイレクト先
    assert_template 'users/show'  # テンプレート
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    
    # ログアウトの検証を追加
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 別のタブでログアウトをシミュレート
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,       count: 0
    assert_select "a[href=?]", user_path(@user),  count: 0
  end
  
  # ログイン(rememberチェック付き)
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # テストプラン１：空白で無いか
    # assert_not_empty cookies['remember_token']
    # テストプラン２：値が一致しているかまで確認
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end
  
  # ログイン(rememberチェックなし)
  test "login without remembering" do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # チェック無しでログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
    
  
end
