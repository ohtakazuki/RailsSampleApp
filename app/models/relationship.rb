class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true  # rails5では省略しても動く(DBで定義されているから?)
  validates :followed_id, presence: true  #   〃
end
