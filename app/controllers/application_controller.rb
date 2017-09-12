class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # 認証まわりを含むのでApplicationでincludeして全部から呼べるようにする
  include SessionsHelper
  
  private
    # ユーザのログインを確認する
    def logged_in_user
      unless logged_in?
        store_location  # 本来行きたかったURLを保存
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
