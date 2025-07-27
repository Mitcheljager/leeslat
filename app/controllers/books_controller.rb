class BooksController < ApplicationController
  before_action :set_book, only: [:show, :listings_summary_partial]

  after_action :request_scrape, only: [:show]
  after_action :request_description, only: [:show]
  after_action :request_cover, only: [:show]

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

    # We set this here rather than in the job so that requests between now and when the
    # job runs don't request another job.
    @book.update(last_scrape_started_at: DateTime.now)

    RequestScrapeJob.perform_async(@book.isbn)
  end

  def request_description
    # Stop if there are no listings with descriptions or a description has already been generated.
    return if @book.listings.where.not(description: nil).none?
    return if @book.description_last_generated_at.present?

    # We set this here rather than in the job so that requests between now and when the
    # job runs don't request another job.
    @book.update(description_last_generated_at: DateTime.now)

    RequestDescriptionJob.perform_async(@book.isbn)
  end

  def request_cover
    puts "==="
    puts @book.cover_image.attached?
    puts @book.cover_last_scraped_at
    puts "==="

    # Stop if book already has a cover of if it has attempted to get the cover before.
    # It's possible a book simply has no cover on Goodreads, in which case we don't want
    # to keep retrying for each request.
    return if @book.cover_image.attached?
    return if @book.cover_last_scraped_at.present?

    # This is also done in the method itself, but we do it here to prevent multiple requests
    # from firing for the same job.
    @book.update(cover_last_scraped_at: DateTime.now)

    RequestCoverJob.perform_async(@book.isbn)
  end
end
