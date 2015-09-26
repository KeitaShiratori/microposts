class FollowersController < ApplicationController
  def index
    @user = User.find(params[:followed_id])
    @user.follower_users
  end
end
