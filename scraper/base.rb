require_relative "../config/environment"
require "httparty"
require "nokogiri"

def get_document(url)
  response = HTTParty.get(url, {
    headers: {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    },
  })

  Nokogiri::HTML(response.body)
end

def save_result(source_name, isbn, title, author, price, currency, url)
  book = get_book(isbn, title, author)
  source = Source.find_by_name!(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = Float(price)
  listing.currency = currency
  listing.url = url
  listing.last_scraped_at = DateTime.now

  listing.save
end

def get_book(isbn, title, author)
  book = Book.find_or_initialize_by(isbn: isbn)

  if book.title.blank? || book.author.blank?
    book.title = title if book.title.blank?
    book.author = author if book.author.blank?

    book.save!
  end

  book
end
