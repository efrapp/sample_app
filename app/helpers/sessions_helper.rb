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
    cookies.permanent[:remember_token] = user.remember_token
    cookies.permanent.signed[:user_id] = user.id
  end

  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      # raise # it is a trick to check if one of the tests covers this part
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    # session[:user_id] != nil
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete :remember_token
    cookies.delete :user_id
  end

  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
