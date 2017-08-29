module UsersHelper
  # 引数で与えられたユーザーのGravatar画像を返す
  def gravatar_for(user, options = { size: 80 })
    # GravatarはメールアドレスをMD5にしたのを引数にするため
    # userモデルのbeforeで小文字にしているが、
    # 当関数を直接他から呼ばれた時用にdowncaseしている
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
