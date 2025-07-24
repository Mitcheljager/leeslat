class AuthorsController < ApplicationController
  before_action :set_author, only: [:show]

  def show
    @books = @author.books
  end

  private

  def set_author
    @author = Author.find_by_slug!(params.expect(:slug))
  end
end
