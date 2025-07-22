class BooksController < ApplicationController
  before_action :set_book, only: [:show]

  def index
    @books = Book.order(created_at: :desc).where.not(last_scrape_finished_at: nil).page(params[:page]).per(20)
  end

  def show
    @listings = @book.listings_with_price
  end

  private

  def set_book
    isbn = params.expect([:slug_and_isbn]).split("-").last
    @book = Book.find_by_isbn!(isbn)
  end
end
