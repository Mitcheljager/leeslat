class ApplicationController < ActionController::Base
  helper_method :theme
  helper_method :theme_dark?
  helper_method :current_user

  def theme
    cookies[:theme]
  end

  def theme_dark?
    theme === "dark" || headers["Sec-CH-Prefers-Color-Scheme"] === "dark"
  end

  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end
end
