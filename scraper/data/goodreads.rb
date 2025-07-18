require_relative "../base"
require "nokogiri"

def get_goodreads_data(isbn)
  goodreads_search_url = "https://www.goodreads.com/search?q=#{isbn}"

  puts "Running Goodreads for: #{goodreads_search_url}"

  document = get_document(goodreads_search_url)

  genres = document.css("[data-testid='genresList'] a").map(&:text)
  format_text = document.css("[data-testid='pagesFormat']").text

  format = "unknown"
  format = "paperback" if format_text.include?("Paperback")
  format = "hardcover" if format_text.include?("Hardcover")

  [genres, format]
end
