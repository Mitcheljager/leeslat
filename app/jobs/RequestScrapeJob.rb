class RequestScrapeJob < ApplicationJob
  queue_as :high_priority

  def perform(isbn, force: false)
    Timeout.timeout(180) do
      puts "Requesting scrape for #{isbn}"

      book = Book.find_by_isbn!(isbn)

      return if !book.requires_scrape? && !force

      # Set the time the scrape was started at. This will be used to determine if the scraper should
      # run again when scraping automatically for potentially outdated data. We use the start time
      # rather than the end time to prevent scraping while it's already scraping.
      book.update!(last_scrape_started_at: DateTime.now)

      begin
        output = `ruby #{Rails.root.join("scraper/run_all_scrapers.rb")} isbn=#{book.isbn} title="#{book.title}"`
        Rails.logger.info output
      rescue => error
        puts error
      ensure
        book.update!(last_scrape_finished_at: DateTime.now)
      end
    rescue Timeout::Error
      Rails.logger.error("RequestScrapeJob timed out for ISBN #{isbn}")
    end
  end
end
