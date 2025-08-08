require_relative "../../config/environment"
require_relative "../helpers/log_time"
require "openai"

def get_openai_keywords(book, client)
  puts "Getting keywords for \"#{book.title}\" (#{book.isbn})..."

  response = client.chat(parameters: {
    model: "gpt-4.1-mini",
    messages: [{
      role: "system",
      content: "You are a summarizer. Your task is to summarize a book by between 5 and 15 keywords in Dutch. These keywords should be comma separated. These keywords should talk about the overall mood, themes, and plot, without spoilers. Avoid general genres like \"Action\" or \"Fantasy\". Titlecase should be used for each keyword, keywords may contain spaces, do not end in a period. The final text should be nothing but comma separated keywords."
    }, {
      role: "user",
      content: "Please provide comma separated Dutch keywords for the book \"#{book.title}\" by #{book.authors[0].name}."
    }],
    temperature: 0.7
  })

  message = response["choices"][0]["message"]["content"].sub(/\.\z/, "") # Remove trailing period that the AI is all to eager to include

  puts "Keywords: #{message}"

  book.update(keywords: message)
end

start_time = DateTime.now

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"], log_errors: true)

arguments = ARGV.map { |a| a.split("=", 2) }.to_h
isbn = arguments["isbn"]
min_hotness = arguments["min_hotness"] || 0

if isbn.present?
  book = Book.find_by_isbn(isbn)

  if book.blank?
    puts "Book with ISBN #{isbn} was not found"
  else
    get_openai_keywords(book, client)
  end
else
  books = Book.where(keywords: nil).where("hotness >= ?", min_hotness)

  books.each_with_index do |book, index|
    puts "\e[44m #{index + 1} out of #{books.size} \e[0m"

    get_openai_keywords(book, client)

    if index % 20 == 0
      puts "Garbage collection..."
      GC.start
    end
  end
end

LogTime.log_end_time(start_time)
