class ApplicationController < ActionController::Base
  helper_method :theme_light?
  helper_method :current_user

  def theme_light?
    cookies[:theme] === "light"
  end

  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end
end
