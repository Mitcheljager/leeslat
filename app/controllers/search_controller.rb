class SearchController < ApplicationController
  def index
    @books = Book.search(params[:query])
  end

  def post
    redirect_to search_path(params[:query])
  end
end
