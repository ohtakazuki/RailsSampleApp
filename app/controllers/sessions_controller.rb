class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # 11.有効でないユーザはログインできなくする
      # # cookieに暗号化したユーザIDを格納する
      # log_in @user
      # # helperのrememberを呼ぶ。チェックしたときだけ
      # params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      # redirect_back_or @user
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      #失敗 ログイン画面を再表示してエラーメッセージを表示する
      # flash.now リクエストが発生した時に消滅する
      flash.now[:danger] = 'メールアドレスまたはパスワードが違います'
      render 'new'
    end
  end
  
  def destroy
    # ログイン中のみログアウトする(別のタブでログアウト対策)
    log_out if logged_in?
    redirect_to root_url
  end
end
