class PagesController < ApplicationController
  def index
    @hot_books = Book.order(hotness: :desc).limit(8)
    @mystery_books = Genre.find_by_slug("mysterie").books.order(hotness: :desc).limit(8)
    @fantasy_books = Genre.find_by_slug("fantasy").books.order(hotness: :desc).limit(8)
    @cook_books = Genre.find_by_slug("kookboeken").books.order(hotness: :desc).limit(8)
  end

  def about
  end
end
