class RetweetsController < ApplicationController
  before_action :logged_in_user

  def create
    @micropost = Micropost.find(params[:micropost_id])
    current_user.retweet(@micropost)
    @m = @micropost
  end

  def destroy
    @m = Retweet.find(params[:id]).micropost

    Retweet.destroy(params[:id])
  end
end