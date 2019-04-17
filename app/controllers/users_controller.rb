class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  # list of registered users
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  # signup form
  def new
    @user = User.new
  end

  # user's profile
  def show
    @user = User.find(params[:id])
    redirect_to(root_url, 
                flash: { warning: 'Please active your account first'}) and
      return unless @user.activated?
  end

  # signup process
  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # log_in @user
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
    else
      render :new
    end
  end

  # edit profile form
  def edit
  end

  # update profile process
  def update
    
    if(@user.update_attributes(user_params))
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      # I need this line becuase update_attribues method assigns the
      # information passed as arguments to the object's attributes
      # method so when the email field is empty the gravar image in
      # the edit form will diseppear becuase we pass an empty email
      # value to the gravatar_for method
      @user.reload
      render :edit
    end
  end

  # destroy user
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, 
                                   :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
