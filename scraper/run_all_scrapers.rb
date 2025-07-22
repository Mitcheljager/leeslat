require_relative "base"
require_relative "sources/amazon"
require_relative "sources/amazon_retourdeals"
require_relative "sources/boekenbalie"
require_relative "sources/boekennl"
require_relative "sources/bruna"
require_relative "sources/libris"
require_relative "sources/voordeelboekenonline"

arguments = ARGV.map { |a| a.split("=", 2) }.to_h
isbn = arguments["isbn"]
title = arguments["title"]
scrapers_to_run = arguments["scrapers"]&.split(",") || []

puts "Running scrapers..."

def run_scraper(source_name, isbn, title)
  puts "Running #{source_name}..."

  result = yield
  save_result(source_name, isbn, **result)

  update_listing_scraping_status(source_name, isbn, was_succesful: true)
rescue => error
  puts "#{source_name} failed for: #{title} - #{isbn}"
  puts "#{error.class}: #{error.message}"
  puts error.backtrace.join("\n")

  update_listing_scraping_status(source_name, isbn, was_succesful: false)
ensure
  puts "---"
end

def run_all_scrapers(isbn, title, scrapers_to_run)
  run_scraper("Amazon", isbn, title)                  { scrape_amazon(isbn) } if is_in_run?(scrapers_to_run, "Amazon")
  run_scraper("Amazon RetourDeals", isbn, title)      { scrape_amazon_retourdeals(isbn) } if is_in_run?(scrapers_to_run, "Amazon RetourDeals")
  run_scraper("Boekenbalie", isbn, title)             { scrape_boekenbalie(isbn, title) } if is_in_run?(scrapers_to_run, "Boekenbalie")
  run_scraper("Boeken.nl", isbn, title)               { scrape_boekennl(isbn, title) } if is_in_run?(scrapers_to_run, "Boeken.nl")
  run_scraper("Bruna", isbn, title)                   { scrape_bruna(isbn, title) } if is_in_run?(scrapers_to_run, "Bruna")
  # [Broken, CF 403] run_scraper("Libris", isbn, title)                  { scrape_libris(isbn) } if is_in_run?(scrapers_to_run, "Libris")
  run_scraper("Voordeelboekenonline.nl", isbn, title) { scrape_voordeelboekenonline(isbn) } if is_in_run?(scrapers_to_run, "Voordeelboekenonline.nl")

  update_book(isbn)
end

def save_result(source_name, isbn, url:, price: 0, currency: "EUR", description: nil, number_of_pages: 0)
  book = get_book(isbn)

  raise "Book was nil" if book.nil?

  source = Source.find_by_name(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = Float(price)
  listing.currency = currency
  listing.url = url
  listing.number_of_pages = number_of_pages if number_of_pages.present?
  listing.description = description if description.present?

  listing.save
end

def update_listing_scraping_status(source_name, isbn, was_succesful:)
  book = Book.find_by_isbn(isbn)
  source = Source.find_by_name(source_name)
  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)

  listing.last_scraped_at = DateTime.now
  listing.was_last_scrape_successful = was_succesful

  listing.save!
end

def update_book(isbn)
  book = Book.find_by_isbn(isbn)

  consolidate_number_of_pages(book)
  book.update(last_scraped_at: DateTime.now)
end

def consolidate_number_of_pages(book)
  return if book.blank?

  number_of_pages_counts = book.listings.where.not(number_of_pages: 0).pluck(:number_of_pages)
  most_common_number_of_pages = number_of_pages_counts.group_by(&:itself).transform_values(&:count).max_by { |_, count| count }&.first

  return if number_of_pages_counts.empty?

  if most_common_number_of_pages && book.number_of_pages != most_common_number_of_pages
    book.update(number_of_pages: most_common_number_of_pages)
  end
end

def is_in_run?(scrapers_to_run, name)
  scrapers_to_run.blank? || scrapers_to_run.include?(name)
end

if isbn && title
  run_all_scrapers(isbn, title, scrapers_to_run)
else
  Book.all.each do |book|
    run_all_scrapers(isbn, title, scrapers_to_run)
  end
end
