class Micropost < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  
  has_many :micropost_retweets, class_name:  "Retweet",
                                     foreign_key: "micropost_id",
                                     dependent:   :destroy
  has_many :micropost_users, through: :micropost_retweets, source: :user
  
  # イイネ機能
  # http://easyramble.com/activerecord-reputation-system.html
  has_reputation :likes, source: :user, aggregated_by: :sum
end
