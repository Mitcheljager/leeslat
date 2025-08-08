class GenresController < ApplicationController
  before_action :set_genre, only: [:show]

  def show
    @hot_books = @genre.books.full_join.includes(:authors, :listings).order(hotness: :desc).limit(8)
    @subgenres = @genre.subgenres
  end

  private

  def set_genre
    @genre = Genre.includes(:books).find_by_slug!(params.expect(:slug))
  end
end
