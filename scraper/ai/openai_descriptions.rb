require_relative "../../config/environment"
require "openai"

isbn = ARGV[0]

book = Book.find_by_isbn(isbn)
if book.blank?
  puts "Book with ISBN #{isbn} was not found"
  return
end

descriptions = book.listings.pluck(:description).compact.uniq
if descriptions.none?
  puts "No descriptions for ISBN #{isbn} were not found"
  return
end

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"], log_errors: true)

puts "Getting description for \"#{book.title}\" (#{book.isbn}) for #{descriptions.length} descriptions..."

response = client.chat(parameters: {
  model: "gpt-4.1-mini",
  messages: [{
    role: "system",
    content: "Your task is to clean up and merge a set of book descriptions you are given. The descriptions will be in Dutch or English and should be returned in the language they were given. The descriptions might include quotes, blurbs, or reviews, which should be removed. The only thing that should remain is a description of the book, without any extras. The description should be close to the original texts without rewording. If different given descriptions contain vastly different text, they should all be included. It's all about cleaning up and concatenating. Grammatical or formatting errors should be fixed, including missing spaces or new lines."
  }, {
    role: "user",
    content: "Please clean up and merge these book descriptions. Please removing awards, reviews, blurbs, quotes, mentions of the author and translator, and mentions edition of this book. Additionally, please fix any grammar or formatting issues or inconsistencies. Insert new lines where relevant:\n
    \n\n" + descriptions.join("\n\n")
  }],
  temperature: 0.7,
})

message = response["choices"][0]["message"]["content"]

puts "Summary: #{message}"

book.update(description: message)
