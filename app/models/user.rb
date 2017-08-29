class User < ApplicationRecord
  # 保存前にメールアドレスを全部小文字にする
  # ruby側では以下の uniqueness: { case_sensitive: false } で大文字小文字を無視できるが
  # データベース側(add_index)では無視できないため
  # before_save { self.email = email.downcase }
  before_save { email.downcase! }
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:   true, length: { maximum: 255 },
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    
  # セキュアなパスワードを持つ
  #   属性password_digestの追加、bcryptをgemで取得
  has_secure_password
  
  # パスワードの存在、最小文字数
  validates :password, presence: true, length: { minimum: 6 }
end
