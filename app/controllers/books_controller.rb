class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.order(created_at: :desc)
  end

  def show
    @listings = @book.listings_with_price
  end

  def new
    @book = Book.new
  end

  def edit
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy!
    redirect_to root_path, notice: "Book was successfully destroyed.", status: :see_other
  end

  private

  def set_book
    isbn = params.expect([:slug_and_isbn]).split("-").last
    @book = Book.find_by_isbn!(isbn)
  end

  def book_params
    params.expect(book: [:title, :subtitle, :description, :isbn, :number_of_pages, :format, :language, :published_date_text, author_ids: [], genre_ids: []])
  end
end
