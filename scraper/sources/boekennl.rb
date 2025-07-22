require_relative "../base"
require "nokogiri"

def scrape_boekennl(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boeken.nl")

  slug = title.parameterize
  url = listing&.url || "https://boeken.nl/boeken/#{isbn}/#{slug}"

  puts "Running Boeken.nl for: " + url

  document = get_document(url)

  # Document was not an actual page, instead it fell back to some overview page
  # In this case we use a search engine to find the actual page, if it exists
  url, document = get_search_document("boeken.nl", isbn) unless document.text.include?("Beoordelingen")

  return { url: nil, available: false } if url.blank? || document.blank?

  price = document.css(".product-info .uc-price").first.text.gsub("€", "").gsub(",", ".").strip
  description = document.css(".field-name-body .nxte-shave-expanding-item").first.text.strip
  number_of_pages = document.css(".field-name-field-page-count .field-item").first.text.strip

  puts price
  puts description
  puts number_of_pages

  { url: url, price: price, description: description, number_of_pages: number_of_pages, available: price.blank? }
end
