require_relative "../base"
require "nokogiri"

def scrape_libris(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Libris")

  if listing&.url
    puts "Running previously fetched url Libris for: " + url
  end

  document = get_document(url) if listing&.url
  url, document = get_search_document("libris.nl", isbn, headers: headers) unless document&.text&.include?("Samenvatting")

  script_tag = document.css("script[type='application/ld+json']")

  return

  price = document.css(".price-large").first.text.strip.gsub(",", ".")
  description = document.css(".description-text").first.text.strip
  number_of_pages_label = document.at_css(".grid-column-6.grid-column-xs-6.body-normal:contains('pagina')")
  number_of_pages = number_of_pages_label&.gsub("pagina's", "")&.strip

  puts title
  puts price
  puts description
  puts number_of_pages

  { url: url, price: price, description: description, number_of_pages: number_of_pages }
end
