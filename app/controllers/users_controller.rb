class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :microposts, :feed, :update, :destroy]
  
  def index
    if !logged_in?
      redirect_to root_url
    end

    search_users
    @micropost = current_user.microposts.build
  end
  
  def search_users
    @users = search_user
  end
  
  def search_microposts
    @microposts = search_micropost
  end

  def show
    if logged_in?
      set_user
      @micropost = @user.microposts.build
      feed
    else
      redirect_to root_url
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      session[:user_id] = @user.id
      flash[:info] = "logged in as #{@user.name}"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = set_user
  end

  # users_controller.rb
  def update
    if !check_old_pwd
      flash[:danger] = 'パスワードが一致しません'
      return render 'edit'
    end
    
    profile = user_profile
    profile.delete(:old_password)

    if @user.update(profile)
      # 保存に成功した場合はトップページへリダイレクト
      flash[:info] = 'メッセージを編集しました'
      redirect_to @user
    else
      # 保存に失敗した場合は編集画面へ戻す
      flash[:danger] = 'この内容は登録できません'
      render 'edit'
    end
  end

  def following
    @following = User.find(params[:follower_id]).following_users
  end
  
  def followers
    @followers = User.find(params[:followed_id]).follower_users
  end
  
  def microposts
    @microposts = @user.microposts
  end
  
  def feed
    @microposts = @user.feed_items.includes(:user)
  end
    

private

  # get parameters for sinup
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
    
  # get parameters for profile editing
  def user_profile
    params.require(:user).permit(:name, :email, :description, :location, :password, :password_confirmation, :old_password)
  end
  
  # get parameters for search
  def search_params
    params.permit(:q)
  end
  
  def check_old_pwd
    if u = params[:user]
      old_pwd = u[:old_password]
      new_pwd = u[:password]
      confirm = u[:password_confirmation]
      return true if old_pwd.blank? && new_pwd.blank? && confirm.blank?
      return false unless old_pwd.presence && new_pwd.presence && confirm.presence
      !!@user.authenticate(old_pwd) 
    else
      false # 通常はここには来ないけど安全策
    end
  end
 
  def set_user
    @user=User.find(params[:id])
  end
  
  def set_keyword_array
  end

  def search_user
    return users = clear_search_condition if params[:q].blank?

    q = search_params[:q]
    session[:q] = q
    keyword_arrays = q.gsub(/　/," ").split()

    # 以下、モデルのクラスメソッドにしたい。
    # 理想は、User.find_by_array(column_name, keyword_arrays)とかにしたい。
    # でもって、Micropostの方と共通化したい。
    users = User.arel_table[:name]
    users_sel = users.matches("\%#{keyword_arrays[0]}\%")
    for i in 1...keyword_arrays.length
      users_sel = users_sel.or(users.matches("\%#{keyword_arrays[i]}\%"))
    end
    logger.debug("SQL: #{User.where(users_sel).to_sql}")

    User.where(users_sel)
  end

  def search_micropost
    return microposts = clear_search_condition if params[:q].blank?
    
    q = search_params[:q]
    session[:q] = q
    keyword_arrays = q.gsub(/　/," ").split()

    # 以下、モデルのクラスメソッドにしたい。
    # 理想は、Micropost.find_by_array(column_name, keyword_arrays)とかにしたい。
    # でもって、Userの方と共通化したい。
    microposts = Micropost.arel_table[:content]
    microposts_sel = microposts.matches("\%#{keyword_arrays[0]}\%")
    for i in 1...keyword_arrays.length
      microposts_sel = microposts_sel.or(microposts.matches("\%#{keyword_arrays[i]}\%"))
    end
    logger.debug("SQL: #{Micropost.where(microposts_sel).to_sql}")

    Micropost.where(microposts_sel)
  end

  def clear_search_condition
    session[:q] = ""
    Array.new()
  end
end
