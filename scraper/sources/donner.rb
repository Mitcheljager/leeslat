require_relative "../base"
require "nokogiri"

def scrape_donner(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Donner")

  # The slug part of the url doesn't actually matter, all that matter is that it contains a - and ISBN.
  # It doesn't even redirect to the actual page, it will serve the page for the given url as long as it
  # contains the ISBN. Makes it nice and easy!
  url = listing&.url || "https://www.donner.nl/producten/-#{isbn}"

  puts "Running Donner for: " + url

  document = get_document(url)

  return { url: nil, available: false } if document.blank? || document.include?("Pagina niet gevonden")

  price = document.at_css(".product-price__price")&.text&.gsub("€", "")&.gsub(",", ".")&.strip
  description = document.at_css(".product-details__description")&.text&.strip
  number_of_pages_label = document.at_css(".product-specifications__item:contains('Pagina')")
  number_of_pages = number_of_pages_label&.text&.gsub("Pagina's", "")&.strip
  available = !document.at_css(".product-details__product").text.include?("Tijdelijk niet leverbaar")

  { url:, price:, description:, number_of_pages:, available:, condition: :new }
end
