require "sidekiq"

class RequestDescriptionJob
  include Sidekiq::Job

  def perform(isbn)
    puts "Requesting description for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    output = `ruby #{Rails.root.join("scraper/ai/openai_descriptions.rb")} #{book.isbn}`
    Rails.logger.info output
  end
end
