require_relative "../get_document"
require_relative "../helpers/date_formatter"

def scrape_voordeelboekenonline(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Voordeelboekenonline.nl")

  url = listing&.url || "https://www.voordeelboekenonline.nl/catalogsearch/result/?q=#{isbn}"

  if listing&.url
    puts "Running previously fetched url Voordeelboekenonline.nl for: " + url
  else
    puts "Running new url for Voordeelboekenonline.nl for: " + url
  end

  url, document = get_document(url, return_url: true)

  # No document was returned or the search stayed on a search page. If the isbn was found it would have
  # redirected to the book page directly.
  # Some ISBN searching return results for other pages some some reason. We double check if the url we
  # entered actually contains the ISBN we're looking for.
  return { url: nil, available: false } if document.nil? || url.include?("catalogsearch") || !url.include?(isbn)

  price = document.css("[data-price-type='finalPrice']").first.attribute("data-price-amount").value.strip
  description = document.css("#descrm .description .value").first.text.strip
  number_of_pages = document.css("[data-th='Bladzijden']").first&.text&.strip
  table = document.css("#product-attribute-specs-table").first
  condition = table.text.include?("Licht beschadigd") ? :damaged : :new
  available = document.text.include?("Product is op voorraad")
  published_date_text = DateFormatter.format_published_date_text(document.css("[data-th='Verschijningsdatum']").first&.text&.strip)

  { url:, price:, description:, number_of_pages:, available:, condition:, published_date_text: }
end
