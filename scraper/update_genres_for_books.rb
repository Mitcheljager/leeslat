require_relative "get_book"
require_relative "data/goodreads"

arguments = ARGV.map { |a| a.split("=", 2) }.to_h
isbn = arguments["isbn"]

def find_genres_for_book(book)
  data = get_goodreads_data(book.isbn)
  parse_genres_for_book(book, data[:genres]) if data[:genres].any?
end

if isbn.present?
  book = Book.find_by_isbn(isbn)
  find_genres_for_book(book)
else
  Book.all.each do |book|
    find_genres_for_book(book)
  end
end
