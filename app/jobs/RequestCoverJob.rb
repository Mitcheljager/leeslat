require "sidekiq"

class RequestCoverJob
  include Sidekiq::Job

  def perform(isbn)
    puts "Requesting cover for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    output = `ruby #{Rails.root.join("scraper/attach_image_for_isbn.rb")} #{book.isbn}`
    Rails.logger.info output
  end
end
