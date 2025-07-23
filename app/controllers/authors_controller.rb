class AuthorsController < ApplicationController
  before_action :set_author, only: [:show]

  def show
  end

  private

  def set_author
    @author = Author.find(params.expect(:id))
  end
end
