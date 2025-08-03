class GenresController < ApplicationController
  before_action :set_genre, only: [:show]

  def show
    @hot_books = @genre.books.order(hotness: :desc).limit(8)
    @subgenres = @genre.subgenres.includes(:books).left_joins(:books).group("genres.id").order("COUNT(books.id) DESC").limit(4)
  end

  private

  def set_genre
    @genre = Genre.includes(:books).find_by_slug!(params.expect(:slug))
  end
end
