class User < ApplicationRecord
  # micropostとの関連付け
  has_many :microposts, dependent: :destroy
  # relationshipとの関連付け
  has_many :active_relationships, class_name: "Relationship",
                                 foreign_key: "follower_id",
                                   dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                 foreign_key: "followed_id",
                                   dependent: :destroy
  # 私がフォローしている人たち(能動的)
  has_many :following, through: :active_relationships, source: :followed
  # 私をフォローしている人たち(受動的)
  has_many :followers, through: :passive_relationships, source: :follower

  # 仮想項目 remember_token を書くためにアクセス可能な属性を定義する
  attr_accessor :remember_token, :activation_token, :reset_token

  # 保存前にメールアドレスを全部小文字にする
  # ruby側では以下の uniqueness: { case_sensitive: false } で大文字小文字を無視できるが
  # データベース側(add_index)では無視できないため
  # before_save { self.email = email.downcase }
  # 直接ブロックで書くより、メソッド参照がおすすめ
  # before_save { email.downcase! }
  before_save :downcase_email
  # オブジェクト作成前に有効化ダイジェストを作成用
  before_create :create_activation_digest
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:   true, length: { maximum: 255 },
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    
  # セキュアなパスワードを持つ
  #   属性password_digestの追加、bcryptをgemで取得
  has_secure_password
  
  # パスワードの存在、最小文字数
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す。Userに関することだからここで
  #   integration test で パスワードダイジェストを作る時
  #   9.1.1 記憶トークンを暗号化する時
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  #   記憶トークン用
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためにユーザをデータベースに記憶する
  def remember
    # self:ローカル変数でなくインスタンス変数に値を設定する
    self.remember_token = User.new_token
    # ダイジェストを更新
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 11.3.1 sendを使ってメタプログラミングする
  # # 渡されたトークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end
  def authenticated?(attribute, token)
    # sendを使ってxxx_digestを取得する
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # アカウントを有効にする
  def activate
    # 11.39 1行にまとめて書ける
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    # 12.20 1行にまとめて書ける
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  
  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # パスワード再設定の期限切れならtrue
  def password_reset_expired?
    # ２時間より前
    reset_sent_at < 2.hours.ago
  end
  
  # feed
  def feed
    # v1 試作：自分だけ
    # Micropost.where("user_id = ? ", id)
    # v2 自分とフォローしているユーザー
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # v3 リファクタ：キーとペア表記
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #  following_ids: following_ids, user_id: id)
    # v4 内部クエリを使った書き方
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end
  
  # ユーザをフォローする
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end
  
  # ユーザをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  # 現在のユーザがフォローしてたらtrueを返す
  def following?(other_user)
    # selfがother_userをフォローしているか
    following.include?(other_user)
  end

  private 
    # メールアドレスをすべて小文字にする
    def downcase_email
      # !破壊的メソッドで省略して書く
      # self.email = email.downcase
      self.email.downcase!
    end
    
    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
