class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # cookieに暗号化したユーザIDを格納する
      log_in user
      redirect_to user
    else
      #失敗 ログイン画面を再表示してエラーメッセージを表示する
      # flash.now リクエストが発生した時に消滅する
      flash.now[:danger] = 'メールアドレスまたはパスワードが違います'
      render 'new'
    end
  end
  
  def destroy
    log_out
    redirect_to root_url
  end
end
