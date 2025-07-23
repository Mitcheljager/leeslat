class Admin::GenresController < Admin::BaseController
  before_action :set_genre, only: [:show]

  def show
  end

  private

  def set_genre
    @genre = Genre.find_by_slug!(params.expect(:slug))
  end
end
