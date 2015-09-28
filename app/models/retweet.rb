class Retweet < ActiveRecord::Base
  belongs_to :micropost, class_name: "Micropost"
  belongs_to :user, class_name: "User"
end
