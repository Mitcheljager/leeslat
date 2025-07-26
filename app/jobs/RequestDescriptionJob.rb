require "sidekiq"

class RequestDescriptionJob
  include Sidekiq::Job

  def perform(isbn)
    puts "Requesting description for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    # Stop if there are no listings with descriptions
    return if book.listings.where.not(description: nil).none?

    output = `ruby #{Rails.root.join("scraper/ai/openai_descriptions.rb")} #{book.isbn}`
    Rails.logger.info output
  end
end
