require_relative "../../config/environment"
require "openai"

isbn = ARGV[0]

book = Book.find_by_isbn(isbn)
return unless book.present?

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"], log_errors: true)

puts "Getting keywords for \"#{book.title}\" (#{book.isbn})..."

response = client.chat(parameters: {
  model: "gpt-3.5-turbo",
  messages: [{
    role: "system",
    content: "You are a summarizer. Your task is to summarize a book by between 10 and 25 keywords in Dutch. These keywords should be comma separated. These keywords should talk about the overall mood, themes, and plot, without spoilers. Avoid general genres like \"Action\" or \"Fantasy\". Titlecase should be used for each keyword, keywords may contain spaces, do not end in a period. The final text should be nothing but comma separated keywords."
  }, {
    role: "user",
    content: "Please provide comma separated Dutch keywords for the book \"#{book.title}\" by #{book.authors[0].name}."
  }],
  temperature: 0.7,
})

message = response["choices"][0]["message"]["content"].sub(/\.\z/, "") # Remove trailing period that the AI is all to eager to include

puts "Keywords: #{message}"

book.update(keywords: message)
