require_relative "../config/environment"
require_relative "data/google_api"
require_relative "data/goodreads"
require "httparty"
require "nokogiri"

def get_document(url, return_url: false, headers: {})
  default_headers = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
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
  search_url = "https://www.bing.com/search?q=site%3A#{source_url}+boek+isbn+%22#{isbn}%22"
  puts "Searching bing for #{isbn} at #{search_url}"

  search_document = get_document(search_url)
  url = search_document.css("h2 a").first.attribute("href")&.value

  puts "URL found through search engine: " + url

  return unless url.include?(source_url)

  url, document = get_document(url, return_url: true, headers: headers)

  puts document.present?

  [url, document]
end

def get_book(isbn, format = nil, language = nil)
  book = Book.find_or_initialize_by(isbn: isbn)

  if book.new_record?
    # Google API is somewhat limited. It has rate limited, but this can be increased on request.
    # It also lacks a lot of books that Goodreads does have, so for we we will rely on Goodreads entirely.
    # is_ebook, title, language, authors, published_date = get_google_api_data(isbn)

    # Not actually using image_url, but I am being lazy with the array format returned from this function.
    genres, format, image_url, is_ebook, title, language, authors, published_date = get_goodreads_data(isbn)

    if is_ebook || title.blank?
      # Store that this book failed to fetch and may be skipped in future runs. Ebooks are always skipped
      # and as such are marked as permanent. Other books may be re-tried over time. A rake task will
      # periodically destroy entries that are not marked as permanent.
      SkippableISBN.create(isbn: isbn, permanent: is_ebook == true)

      raise "Given book \"#{title}\" (#{isbn}) is an ebook" if is_ebook
      raise "No title was returned for #{isbn}" if title.blank?
    end

    # Some titles include a :, which (almost?) always mean it's a title followed by a subtitle
    main_title, subtitle = title.split(":", 2).map(&:strip)

    book.title = main_title
    book.subtitle = subtitle if subtitle.present?
    book.language = language
    book.format = format
    book.published_date_text = published_date if published_date

    parse_authors_for_book(book, authors) if authors.present?

    book.save!
  end

  book
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
  book&.listings&.joins(:source)&.find_by(sources: { name: source_name })
end
