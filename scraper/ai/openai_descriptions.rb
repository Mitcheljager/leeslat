require_relative "../../config/environment"
require "openai"

isbn = ARGV[0]

book = Book.find_by_isbn(isbn)
return unless book.present?

descriptions = book.listings.pluck(:description).compact.uniq
return unless descriptions.any?

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"], log_errors: true)

puts "Getting description for \"#{book.title}\" (#{book.isbn}) for #{descriptions.length} descriptions..."

response = client.chat(parameters: {
  model: "gpt-3.5-turbo",
  messages: [{
    role: "system",
    content: "Your task is to clean up and merge a set of book descriptions you are given. The descriptions will be in Dutch or English and should be returned in the language they were given. The descriptions might include quotes, blurb or reviews, which should be removed. The only thing that should be returned is a description of the book, without any extras. The final description should be close to the original text without rewording. If different given descriptions contain vastly different text, they should all be included. The description would be what you might find on the back flap. It's all about cleaning up and concatenating, rather than rewording. Grammatical or formatting errors may be fixed. If no content is relevant please return nothing.
    Important: Any text mentioning the edition of the book should be removed.
    Important: Any text regarding the author or translator should be removed."
  }, {
    role: "user",
    content: "Please clean up and merge these book descriptions, removing reviews, blurbs, quotes, mentions of the author and translator, and mentions of the edition of this book:\n\n" + descriptions.join("\n\n")
  }],
  temperature: 0.7,
})

message = response["choices"][0]["message"]["content"]

puts "Summary: #{message}"

book.update(description: message)
