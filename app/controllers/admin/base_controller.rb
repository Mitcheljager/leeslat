class Admin::BaseController < ApplicationController
  before_action :redirect_unless_admin

  def index
  end
end
