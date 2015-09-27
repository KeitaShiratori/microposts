class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build
      @microposts = Micropost.page(params[:page])
    end
  end
end
