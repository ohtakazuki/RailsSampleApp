class UsersController < ApplicationController
  def show
    # viewに渡す
    @user = User.find(params[:id])
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
      # flash による次画面でのメッセージ表示
      flash[:success] = "ユーザを登録しました。ようこそ Sample App へ！"
      redirect_to @user
    else
      render 'new'
    end
  end

  private
    # Strong Parameters対応。userモデル用のハッシュを返す
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
