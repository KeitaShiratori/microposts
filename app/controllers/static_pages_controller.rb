class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build
      @microposts = Micropost.page(params[:page]).find_with_reputation(:likes, :all).order('likes desc', 'created_at desc')
    end
  end
end
