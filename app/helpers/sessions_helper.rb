module SessionsHelper

  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    user.remember

    # Common way
    # cookies[:remember_token] = { value: user.remember_token,
    #                              expires: 20.years.from.now.utc }

    # Rails way. It manages internally the expires option with the
    # permanent() method
    cookies.permanent.signed[:remember_token] = user.remember_token
    cookies.permanent.signed[:user_id] = user.id
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        login_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    # session[:user_id] != nil
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
