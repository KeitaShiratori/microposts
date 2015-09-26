class FollowingsController < ApplicationController
  def index
    @user = User.find(params[:follower_id])
    @user.following_users
  end

end
