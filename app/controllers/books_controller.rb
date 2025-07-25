class BooksController < ApplicationController
  before_action :set_book, only: [:show]

  after_action :request_scrape, only: [:show]

  def index
    @books = Book.order(created_at: :desc).where.not(last_scrape_finished_at: nil).page(params[:page])
  end

  def show
    @listings = @book.listings_with_price
  end

  private

  def set_book
    isbn = params.expect([:slug_and_isbn]).split("-").last
    @book = Book.find_by_isbn!(isbn)
  end

  def request_scrape
    return if @book.last_scrape_started_at.present? && @book.last_scrape_started_at > 1.day.ago

    @book.update(last_scrape_started_at: DateTime.now)

    RequestScrapeJob.perform_async(@book.isbn)
  end
end
