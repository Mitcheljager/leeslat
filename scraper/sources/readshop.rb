require_relative "../base"
require "nokogiri"

# This is the same as the Bruna scraper. Totally and lazily copy pasted.
def scrape_readshop(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Readshop")

  slug = title.parameterize
  url = listing&.url || "https://www.readshop.nl/boeken/#{slug}-#{isbn}"

  puts "Running Readshop for: " + url

  document = get_document(url)

  # Document was not an actual page, instead it fell back to some overview page
  # In this case we use a search engine to find the actual page, if it exists
  url, document = get_search_document("readshop.nl", isbn) unless document.text.include?("| Boek |")

  return { url: nil, available: false } if url.blank? || !url.include?("/boeken/") || document.blank?

  price = document.css(".price-block .colored.huge").first.text.strip.tr(",", ".")
  description = document.css(".description .line-clamp-8").first.text.split("Veelgestelde vragen").first.strip
  number_of_pages_label = document.css(".product-meta-description div:nth-child(3)").first
  number_of_pages = number_of_pages_label&.text&.strip
  available = !document.text.include?("Tijdelijk niet voorradig")

  { url:, price:, description:, number_of_pages:, available:, condition: :new }
end
