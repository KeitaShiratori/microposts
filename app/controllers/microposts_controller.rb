class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
    else
      flash[:danger] = 'この内容は登録できません'
    end
    @microposts = Micropost.page(params[:page])
    redirect_to request.referrer
  end
  
  def destroy
    @micropost = current_user.microposts.find_by(id: params[:id])
    return redirect_to root_url if @micropost.nil?
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end
  
  def vote
    @micropost = Micropost.find(params[:id])
    message_id = format("%03d", Random.rand(1 .. 10))
    if params[:type] == "up"
      @micropost.add_evaluation(:likes, 1, current_user)
      message = I18n.t("micropost_vote.genki_#{message_id}")
    else 
      @micropost.delete_evaluation(:likes, current_user)
      message = I18n.t("micropost_vote.cancel_#{message_id}")
    end
    flash.now[:info] = message
  end

  private
  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
