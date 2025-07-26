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
sources_to_run = arguments["sources"]&.split(",") || []

puts "Running scrapers..."

def run_scraper(source_name, isbn, title)
  puts "Running #{source_name}..."

  begin
    result = yield || {}

    save_result(source_name, isbn, **result)
    update_listing_scraping_status(source_name, isbn, was_successful: true)
  rescue => error
    puts "#{source_name} failed for: #{title} - #{isbn}"
    puts "#{error.class}: #{error.message}"
    puts error.backtrace.join("\n")

    save_unsuccessful_result(source_name, isbn)
    update_listing_scraping_status(source_name, isbn, was_successful: false)
  ensure
    puts "---"
  end
end

def run_all_scrapers(isbn, title, sources_to_run)
  run_scraper("Amazon", isbn, title)                  { scrape_amazon(isbn) } if is_in_run?(sources_to_run, "Amazon")
  run_scraper("Amazon RetourDeals", isbn, title)      { scrape_amazon_retourdeals(isbn) } if is_in_run?(sources_to_run, "Amazon RetourDeals")
  run_scraper("Boekenbalie", isbn, title)             { scrape_boekenbalie(isbn, title) } if is_in_run?(sources_to_run, "Boekenbalie")
  run_scraper("Boeken.nl", isbn, title)               { scrape_boekennl(isbn, title) } if is_in_run?(sources_to_run, "Boeken.nl")
  run_scraper("Bruna", isbn, title)                   { scrape_bruna(isbn, title) } if is_in_run?(sources_to_run, "Bruna")
  # [Broken, CF 403] run_scraper("Libris", isbn, title)                  { scrape_libris(isbn) } if is_in_run?(sources_to_run, "Libris")
  run_scraper("Voordeelboekenonline.nl", isbn, title) { scrape_voordeelboekenonline(isbn) } if is_in_run?(sources_to_run, "Voordeelboekenonline.nl")

  update_book(isbn)
end

def save_result(source_name, isbn, url:, price: 0, currency: "EUR", description: nil, number_of_pages: 0, condition: :unknown, condition_details: nil, available: true, published_date_text: nil, includes_shipping: false)
  book = get_book(isbn)

  raise "Book was nil" if book.nil?

  source = Source.find_by_name(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = Float(price || 0)
  listing.currency = currency
  listing.url = url
  listing.number_of_pages = number_of_pages
  listing.description = description
  listing.condition = condition
  listing.condition_details = condition_details
  listing.available = available
  listing.published_date_text = published_date_text if published_date_text.present?
  listing.includes_shipping = includes_shipping

  listing.save
end

# An unsuccessful result means the scrape returned errors. It doesn't mean the scrape simply found nothing.
# Finding nothing is perfectly valid and should be handled in save_result by setting available to false
def save_unsuccessful_result(source_name, isbn)
  book = get_book(isbn)

  raise "Book was nil" if book.nil?

  source = Source.find_by_name(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = 0
  listing.currency = nil
  listing.url = nil
  listing.available = false

  listing.save
end

def update_listing_scraping_status(source_name, isbn, was_successful:)
  book = Book.find_by_isbn(isbn)
  source = Source.find_by_name(source_name)
  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)

  listing.last_scraped_at = DateTime.now
  listing.was_last_scrape_successful = was_successful

  listing.save!
end

def update_book(isbn)
  book = Book.find_by_isbn(isbn)

  consolidate_number_of_pages(book)
  consolidate_published_date_text(book)

  book.update(last_scrape_finished_at: DateTime.now)
end

def consolidate_number_of_pages(book)
  number_of_pages_counts = book.listings.where.not(number_of_pages: 0).pluck(:number_of_pages)
  most_common_number_of_pages = number_of_pages_counts.group_by(&:itself).transform_values(&:count).max_by { |_, count| count }&.first

  return if number_of_pages_counts.empty?

  if most_common_number_of_pages && book.number_of_pages != most_common_number_of_pages
    book.update(number_of_pages: most_common_number_of_pages)
  end
end

# In some cases books scraped from Goodreads don't have published dates, but listings might have them
def consolidate_published_date_text(book)
  return if book.published_date_text.present?

  published_date_text_counts = book.listings.where.not(published_date_text: nil).pluck(:published_date_text)
  most_common_published_date_text = published_date_text_counts.group_by(&:itself).transform_values(&:count).max_by { |_, count| count }&.first

  return if published_date_text_counts.empty?

  if most_common_published_date_text && book.number_of_pages != most_common_published_date_text
    book.update(published_date_text: most_common_published_date_text)
  end
end

def is_in_run?(sources_to_run, name)
  sources_to_run.blank? || sources_to_run.include?(name)
end

start_time = DateTime.now

if isbn.present? && title.present?
  run_all_scrapers(isbn, title, sources_to_run)
else
  Book.all.each_with_index do |book, index|
    puts "-----------------------------------------------------"
    puts "Running scrapers for \"#{book.title}\" (#{book.isbn}) - #{index + 1} out of #{Book.all.size}"
    puts "-----------------------------------------------------"

    run_all_scrapers(book.isbn, book.title, sources_to_run)
  end
end

end_time = DateTime.now
total_seconds = ((end_time - start_time) * 24 * 60 * 60).to_f
minutes = (total_seconds / 60).to_i
seconds = (total_seconds % 60).round(2)

puts "===================="
puts "Run started at #{start_time}"
puts "Run ended at #{end_time}"
puts "Total time: #{minutes} minutes and #{seconds} seconds"
puts "===================="
