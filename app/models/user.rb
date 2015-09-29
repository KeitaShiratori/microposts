class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  
  # バリデーション定義
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :description, length: { maximum: 500 }
  validates :location, length: { maximum: 100 }
  has_secure_password
  
  # リレーションシップ定義
  has_many :microposts
  has_many :following_relationships, class_name:  "Relationship",
                                     foreign_key: "follower_id",
                                     dependent:   :destroy
  has_many :following_users, through: :following_relationships, source: :followed
  has_many :follower_relationships, class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy
  has_many :follower_users, through: :follower_relationships, source: :follower

  has_many :user_retweets,          class_name:  "Retweet",
                                    foreign_key: "user_id",
                                    dependent:   :destroy
  has_many :user_microposts, through: :user_retweets, source: :micropost
  
  # モデルメソッド定義
  # 他のユーザーをフォローする
  def follow(other_user)
    following_relationships.create(followed_id: other_user.id)
  end

  # フォローしているユーザーをアンフォローする
  def unfollow(other_user)
    following_relationships.find_by(followed_id: other_user.id).destroy
  end

  # あるユーザーをフォローしているかどうか？
  def following?(other_user)
    following_users.include?(other_user)
  end
  
  def feed_items
    cond1 = Micropost.where('retweets.user_id' => following_user_ids)
    cond2 = Micropost.where('microposts.user_id' => following_user_ids)
    
    cond1 = cond1.where_values.reduce(:and)
    cond2 = cond2.where_values.reduce(:and)
    
    Micropost.joins("LEFT JOIN retweets ON microposts.id = retweets.micropost_id").where(cond1.or(cond2)).uniq
  end

  # リツイート関係のメソッド
  # あるmicropostをリツイートする
  def retweet(micropost)
    user_retweets.create(micropost_id: micropost.id)
  end

  # フォローしているユーザーをアンフォローする
  def unretweet(micropost)
    user_retweets.find_by(micropost_id: micropost.id).destroy
  end

  # あるユーザーをフォローしているかどうか？
  def retweet?(micropost)
    user_microposts.include?(micropost)
  end
  
end
