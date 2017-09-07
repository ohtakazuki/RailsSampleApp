class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # パラメタ:pageはwill_paginateによって自動生成される
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def show
    # viewに渡す
    @user = User.find(params[:id])
    #redirect_to root_url and return unless !@user.activated?
  end

  def new
    @user = User.new
  end

  def create
    # 以下だとStrong Parameters 機能により例外が発生する
    #   ActiveModel::ForbiddenAttributesError Exception
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    if @user.save
      # メール認証による変更
      # # 登録と共にログインさせる
      # log_in @user
      # # flash による次画面でのメッセージ表示
      # flash[:success] = "ユーザを登録しました。ようこそ Sample App へ！"
      # redirect_to @user
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url

    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    # Strong Parametersを使う
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private
    # Strong Parameters対応。userモデル用のハッシュを返す
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    # beforeアクション
    
    # ログイン済ユーザかどうか確認
    def logged_in_user
      unless logged_in?
        store_location  # 本来行きたかったURLを保存
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    
    # (ログインしているユーザが)正しいユーザかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
