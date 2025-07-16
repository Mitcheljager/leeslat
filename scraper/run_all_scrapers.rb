require_relative "sources/boekennl"
require_relative "sources/boekenbalie"
require_relative "sources/amazon"

isbn = ARGV[0]
title = ARGV[1]

def run_scraper(name, isbn, title)
  puts "Running #{name}..."
  yield
rescue => error
  puts "#{name} failed for: #{title} - #{isbn}"
  puts error
ensure
  puts "---"
end

def run_all_scrapers(isbn, title)
  run_scraper("Boekenbalie", isbn, title) { scrape_boekenbalie(isbn, title) }
  run_scraper("Boeken.nl", isbn, title)   { scrape_boekennl(isbn, title) }
  run_scraper("Amazon", isbn, title)      { scrape_amazon(isbn) }
end

if isbn && title
  run_all_scrapers(isbn, title)
else
  Book.all.each do |book|
    run_all_scrapers(book.isbn, book.title)
  end
end
