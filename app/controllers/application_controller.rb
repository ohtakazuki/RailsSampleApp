class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # 認証まわりを含むのでApplicationでincludeして全部から呼べるようにする
  include SessionsHelper
end
