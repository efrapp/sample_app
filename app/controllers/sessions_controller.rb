class SessionsController < ApplicationController
  def new
  end

  def create
    # I think we use user instead of @user here because the sessions
    # 'resource' doesn't use a model to get validations so an instance
    # variable here doesn't have errors (from model validations) to 
    # show in the view
    user = User.find_by(email: params[:sessions][:email])

    if user && user.authenticate(params[:sessions][:password].downcase)
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  private

    def session_params
      params.require(:sessions).permit(:email, :password)
    end
end
