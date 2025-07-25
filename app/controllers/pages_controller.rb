class PagesController < ApplicationController
  def index
    @sources = Source.all
    @books = Book.limit(8)
  end
end
