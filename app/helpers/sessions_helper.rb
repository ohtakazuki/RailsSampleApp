module SessionsHelper
  
  # 渡されたユーザでログインする
  def log_in(user)
    # cookiesに暗号化済みのユーザーIDが作成される
    # sessionはブラウザを閉じると消える
    session[:user_id] = user.id
  end
  
  # 現在ログイン中のユーザを返す(いる場合)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  # ユーザがログインしていればtrueを返す
  def logged_in?
    !current_user.nil?
  end
  
  # 現在のユーザをログアウトする
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
    
end
