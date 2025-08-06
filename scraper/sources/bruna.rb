require_relative "../get_document"

def scrape_bruna(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Bruna")

  slug = title.parameterize
  url = listing&.url || "https://bruna.nl/boeken/#{slug}-#{isbn}"

  puts "Running Bruna for: " + url

  document = get_document(url)

  # Document was not an actual page, instead it fell back to some overview page
  # In this case we use a search engine to find the actual page, if it exists
  url, document = get_search_document("bruna.nl", isbn) unless document.text.include?("| Boek |")

  return { url: nil, available: false } if url.blank? || !url.include?("/boeken/") || document.blank?

  price = document.at_css(".price-block .colored")&.text&.strip || 0
  description = document.at_css(".description .line-clamp-8")&.text&.split("Veelgestelde vragen")&.first&.strip
  number_of_pages_label = document.at_css(".product-meta-description div:nth-child(3)")
  number_of_pages = number_of_pages_label&.text&.strip
  available = !document.text.include?("Tijdelijk niet voorradig")

  { url:, price:, description:, number_of_pages:, available:, condition: :new }
end
