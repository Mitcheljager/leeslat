require_relative "sources/boekennl"
require_relative "sources/boekenbalie"
require_relative "sources/amazon"

isbn = ARGV[0]
title = ARGV[1]
scrapers_to_run = ARGV[2..]

def run_scraper(name, isbn, title)
  puts "Running #{name}..."

  result = yield
  save_result(name, isbn, **result)
rescue => error
  puts "#{name} failed for: #{title} - #{isbn}"
  puts error
ensure
  puts "---"
end

def run_all_scrapers(isbn, title, scrapers_to_run)
  run_scraper("Boekenbalie", isbn, title) { scrape_boekenbalie(isbn, title) } if is_in_run?(scrapers_to_run, "Boekenbalie")
  run_scraper("Boeken.nl", isbn, title)   { scrape_boekennl(isbn, title) } if is_in_run?(scrapers_to_run, "Boeken.nl")
  run_scraper("Amazon", isbn, title)      { scrape_amazon(isbn) } if is_in_run?(scrapers_to_run, "Amazon")

  consolidate_number_of_pages(isbn)
end

def consolidate_number_of_pages(isbn)
  book = Book.find_by(isbn: isbn)

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
