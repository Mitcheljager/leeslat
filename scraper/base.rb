require_relative "../config/environment"
require "httparty"
require "nokogiri"

def get_document(url)
  response = HTTParty.get(url, {
    headers: {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    },
  })

  if response.code === 200
    Nokogiri::HTML(response.body)
  else
    puts "Response for #{url} failed with code " + response.code.to_s
  end
end

def save_result(source_name, isbn, price, currency, url)
  book = get_book(isbn)
  source = Source.find_by_name!(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = Float(price)
  listing.currency = currency
  listing.url = url
  listing.last_scraped_at = DateTime.now

  listing.save
end

def get_book(isbn, format: nil)
  book = Book.find_or_initialize_by(isbn: isbn)

  if book.new_record?
    google_api_url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}"

    puts "Running Google API for: #{google_api_url}"

    book_data_response = HTTParty.get(google_api_url)
    parsed_response = JSON.parse(book_data_response.body)

    return if parsed_response["totalItems"] === 0 || parsed_response["items"].blank?

    item = parsed_response["items"][0]
    volume_info = item["volumeInfo"]
    sale_info = item["saleInfo"]

    return if sale_info["isEbook"] === true

    parse_authors_for_book(book, volume_info["authors"]) if volume_info["authors"].present?

    book.title = volume_info["title"]
  end

  book.save!
end

def parse_authors_for_book(book, authors)
  authors.each do |author_name|
    author_name = author_name.sub(/\s*\(.*\)\s*$/, '')

    author = Author.find_or_create_by!(name: author_name)

    book.authors << author unless book.authors.include?(author)
  end
end

