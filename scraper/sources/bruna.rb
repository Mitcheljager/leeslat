require_relative "../base"
require "nokogiri"

def scrape_bruna(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Bruna")

  slug = title.parameterize
  url = listing&.url || "https://bruna.nl/boeken/#{slug}-#{isbn}"

  puts "Running Bruna for: " + url

  document = get_document(url)

  # Document was not an actual page, instead it fell back to some overview page
  # In this case we use a search engine to find the actual page, if it exists
  url, document = get_search_document("bruna.nl", isbn) unless document.text.include?("Overzicht")

  return { url: nil, available: false } if url.blank? || document.blank?

  price = document.css(".price-block .colored").first.text.strip
  description = document.css(".description .line-clamp-8").first.text.strip
  number_of_pages_label = document.css(".product-meta-description div:nth-child(3)").first
  number_of_pages = number_of_pages_label&.text&.strip
  available = !document.text.include?("Tijdelijk niet voorradig")

  puts price
  puts description
  puts number_of_pages

  { url: url, price: price, description: description, number_of_pages: number_of_pages, available: available }
end
