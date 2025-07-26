class PagesController < ApplicationController
  def index
    @sources = Source.all
    @books = Book.order(hotness: :desc).limit(8)
  end
end
