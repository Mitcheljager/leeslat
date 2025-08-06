require_relative "../get_document"

def scrape_boekenkraam(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boekenkraam")

  # Similar to Donner, the url is split in isbn and slug. Here it's /boek/isbn/slug.
  # It doesn't matter what the slug as, as long as it's present at all. Here we're just
  # using a -.
  url = listing&.url || "https://www.boekenkraam.nl/boek/#{isbn}/-"

  puts "Running Boekenkraam for: " + url

  document = get_document(url)

  # Boekenkraam doesn't return a 404 or even a page at all when the page doesn't exist.
  # It simply returns nothing at all.
  return { url: nil, available: false } if document.blank? || document&.text.strip.empty?

  price = document.at_css(".newprice")&.text&.gsub("€", "")&.gsub(",", ".")&.strip
  description = document.at_css(".book-description")&.text&.gsub("Omschrijving", "")&.strip
  condition = number_of_pages_label = document.at_css(".book-detail-overview")&.text&.include?("Licht beschadigd") ? :damaged : :new
  number_of_pages_label = document.at_css(".book-detail-overview tr:contains('Aantal Pagina')")
  number_of_pages = number_of_pages_label&.text&.gsub("Aantal Pagina's:", "")&.strip
  available = document.at_css(".add-cart")&.text&.include?("Toevoegen") || false

  { url:, price:, description:, number_of_pages:, available:, condition: }
end
