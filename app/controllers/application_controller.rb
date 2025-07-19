class ApplicationController < ActionController::Base
  helper_method :theme_light?

  def theme_light?
    cookies[:theme] === "light"
  end
end
