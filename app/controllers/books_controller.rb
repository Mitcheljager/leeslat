class BooksController < ApplicationController
  before_action :set_book, only: [:show, :listings_summary_partial]
  before_action :redirect_isbn, only: [:index]

  after_action :request_scrape, only: [:show]
  after_action :request_description, only: [:show]
  after_action :request_cover, only: [:show]

  def index
    @books = BookFilter.new(Book.all, filter_params).filter.page(params[:page])
  end

  def show
  end

  def listings_summary_partial
    return head :no_content if @book.requires_scrape? || @book.is_scrape_ongoing?

    render partial: "book_listings_summary"
  end

  private

  def set_book
    isbn = params.expect([:slug_and_isbn]).split("-").last
    @book = Book.includes(:authors, listings: :source).find_by_isbn!(isbn)
    @listings = @book.listings_with_price
  end

  def redirect_isbn
    return unless params[:query]

    is_isbn = params[:query].match?(/\A97[89]\d{10}\z/)

    return unless is_isbn

    book = Book.find_by_isbn(params[:query])

    redirect_to book if book.present?
  end

  def request_scrape
    return unless @book.requires_scrape?

    puts "Requested new scrape"

    RequestScrapeJob.perform_later(@book.isbn)
  end

  def request_description
    # Stop if there are no listings with descriptions or a description has already been generated.
    return if @book.listings.where.not(description: nil).none?
    return if @book.description_last_generated_at.present?

    puts "Requested new description"

    RequestDescriptionJob.perform_later(@book.isbn)
  end

  def request_cover
    # Stop if book already has a cover of if it has attempted to get the cover before.
    # It's possible a book simply has no cover on Goodreads, in which case we don't want
    # to keep retrying for each request.
    return if @book.cover_image.attached?
    return if @book.cover_last_scraped_at.present?

    puts "Requested new cover"

    RequestCoverJob.perform_later(@book.isbn)
  end
end
