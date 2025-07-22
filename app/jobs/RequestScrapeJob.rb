require "sidekiq"

class RequestScrapeJob
  include Sidekiq::Job

  def perform(isbn)
    puts "Requesting scrape for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    # Set the time the scrape was started at. This will be used to determine if the scraper should
    # run again when scraping automatically for potentially outdated data. We use the start time
    # rather than the end time to prevent scraping while it's already scraping.
    book.update!(last_scrape_started_at: DateTime.now)

    output = `ruby #{Rails.root.join("scraper/run_all_scrapers.rb")} isbn=#{book.isbn} title="#{book.title}"`
    Rails.logger.info output

    book.update!(last_scrape_finished_at: DateTime.now)
  end
end
