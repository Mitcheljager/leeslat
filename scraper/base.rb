require_relative "../config/environment"
require_relative "data/google_api"
require_relative "data/goodreads"
require "httparty"
require "nokogiri"

def get_document(url, return_url: false, headers: {})
  default_headers = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36",
  }

  response = HTTParty.get(url, {
    headers: default_headers.merge(headers)
  })

  if response.code == 200 || response.code == 202
    body = Nokogiri::HTML(response.body)

    if return_url
      url = response.request.last_uri.to_s
      [url, body]
    else
      body
    end
  else
    puts "Response for #{url} failed with code " + response.code.to_s
  end
end

# Used as a fallback if accessing a URL directly via an inferred path is not possible
def get_search_document(source_url, isbn, headers: {})
  search_url = "https://www.bing.com/search?q=site%3A#{source_url}+#{isbn}"
  puts "Searching bing for #{isbn} at #{search_url}"

  search_document = get_document(search_url)
  url = search_document.css("h2 a").first.attribute("href")&.value

  puts "source " + source_url
  puts "url " + url

  return unless url.include?(source_url)

  url, document = get_document(url, return_url: true, headers: headers)

  puts document.present?

  [url, document]
end

def save_result(source_name, isbn, url:, price: 0, currency: "EUR", description: nil, number_of_pages: 0)
  book = get_book(isbn)

  throw "Book was nil" if book.nil?

  source = Source.find_by_name(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = Float(price)
  listing.currency = currency
  listing.url = url
  listing.number_of_pages = number_of_pages if number_of_pages.present?
  listing.description = description if description.present?

  listing.save
end

def get_book(isbn, format = nil, language = nil)
  book = Book.find_or_initialize_by(isbn: isbn)

  if book.new_record?
    is_ebook, title, language, authors, published_date = get_google_api_data(isbn)

    return nil if is_ebook === true

    genres, format = get_goodreads_data(isbn)

    book.title = title
    book.language = language
    book.format = format
    book.published_date_text = published_date if published_date

    parse_authors_for_book(book, authors) if authors.present?

    book.save!
  end

  return book
end

def parse_authors_for_book(book, authors)
  authors.each do |author_name|
    author_name = author_name.sub(/\s*\(.*\)\s*$/, '')

    author = Author.find_or_create_by!(name: author_name)

    book.authors << author unless book.authors.include?(author)
  end
end

def parse_genres_for_book(book, genre_names)
  genre_names.each do |genre_name|
    clean_genre = genre_name.strip.downcase

    genre = Genre.find_by('LOWER(name) = ?', clean_genre)

    # Try to find by keywords if not found by name
    if genre.nil?
      genre = Genre.all.find do |g|
        g.separated_keywords.map(&:downcase).include?(clean_genre)
      end
    end

    next unless genre
    next if book.genres.include?(genre)

    puts "Adding genre \"#{genre.name}\" to book \"#{book.title}\""

    book.genres << genre
  end
end

def find_listing_for_isbn_and_source_name(isbn, source_name)
  book = Book.find_by_isbn(isbn)
  listing = book&.listings&.joins(:source)&.find_by(sources: { name: source_name })
end

