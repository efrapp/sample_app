class SessionsController < ApplicationController
  def new
  end

  def create
    # I think we use user instead of @user here because the sessions
    # 'resource' doesn't use a model to get validations so an instance
    # variable here doesn't have errors (from model validations) to 
    # show in the view
    # 
    # Update 11/04/2019
    # user will be changed to @user becuase we need to access the
    # virtual field :remember_token in the integration test using
    # the assigns method of Ministest
    @user = User.find_by(email: params[:session][:email])

    if @user && @user.authenticate(params[:session][:password].downcase)
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      redirect_to @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

    def session_params
      params.require(:session).permit(:email, :password)
    end
end
