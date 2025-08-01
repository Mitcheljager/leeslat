require "sidekiq"

class RequestCoverJob
  include Sidekiq::Job

  def perform(isbn, force: false)
    puts "Requesting cover for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    return if book.cover_last_scraped_at.present? && !force

    book.update(cover_last_scraped_at: DateTime.now)

    begin
      output = `ruby #{Rails.root.join("scraper/attach_image_for_isbn.rb")} #{book.isbn}`
      Rails.logger.info output
    rescue => error
      puts error
    end
  end
end
