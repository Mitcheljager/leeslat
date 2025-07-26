class BooksController < ApplicationController
  before_action :set_book, only: [:show, :listings_summary_partial]

  after_action :request_scrape, only: [:show]

  def index
    @books = BookFilter.new(Book.all, filter_params).filter.page(params[:page])
  end

  def show
  end

  def listings_summary_partial
    return nil if @book.is_scrape_ongoing?

    render partial: "book_listings_summary"
  end

  private

  def set_book
    isbn = params.expect([:slug_and_isbn]).split("-").last
    @book = Book.includes(:authors, :listings).find_by_isbn!(isbn)
    @listings = @book.listings_with_price
  end

  def request_scrape
    return unless @book.requires_scrape?

    @book.update(last_scrape_started_at: DateTime.now)

    RequestScrapeJob.perform_async(@book.isbn)
  end
end
