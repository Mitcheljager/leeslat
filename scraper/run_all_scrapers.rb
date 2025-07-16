require_relative "boeken"
require_relative "boekenbalie"
require_relative "amazon"

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

run_scraper("Boekenbalie", isbn, title) { scrape_boekenbalie(isbn, title) }
run_scraper("Amazon", isbn, title)      { scrape_amazon(isbn) }
