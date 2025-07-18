class GenresController < ApplicationController
  before_action :set_genre, only: [:show, :edit, :update, :destroy]


  def index
    @genres = Genre.all
  end


  def show
  end


  def new
    @genre = Genre.new
  end


  def edit
  end


  def create
    @genre = Genre.new(genre_params)

    if @genre.save
      redirect_to @genre, notice: "Genre was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def update
    if @genre.update(genre_params)
      redirect_to @genre, notice: "Genre was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @genre.destroy!
    redirect_to genres_path, notice: "Genre was successfully destroyed.", status: :see_other
  end

  private

  def set_genre
    @genre = Genre.find_by_slug!(params.expect(:slug))
  end


  def genre_params
    params.expect(genre: [:name, :slug, :parent_genre_id, :keywords])
  end
end
