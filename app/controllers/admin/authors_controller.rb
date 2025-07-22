class Admin::AuthorsController < Admin::BaseController
  before_action :set_author, only: [:show, :edit, :update, :destroy]

  def index
    @authors = Author.all
  end

  def show
  end

  def new
    @author = Author.new
  end

  def edit
  end

  def create
    @author = Author.new(author_params)

    if @author.save
      redirect_to @author, notice: "Author was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @author.update(author_params)
      redirect_to @author, notice: "Author was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @author.destroy!
    redirect_to authors_path, notice: "Author was successfully destroyed.", status: :see_other
  end

  private

  def set_author
    @author = Author.find(params.expect(:id))
  end

  def author_params
    params.expect(author: [:name])
  end
end
