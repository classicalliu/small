class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  protected

  def log_in user
    session[:user_id] = user.id
  end

  def log_out
    @current_user = nil
    reset_session

    redirect_to posts_path
  end

  def current_user
    @current_user ||= User.find_by_id session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def login_required
    unauthorized! unless logged_in?
  end

  def author_required
    login_required
    redirect_to posts_path unless current_user.author?
  end

  def unauthorized!
    if !request.xhr?
      session[:return_to] = request.env['REQUEST_URI']
      redirect_to new_session_path
    else
      session[:return_to] = request.referrer
      not_found
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

end
