require_relative "../base"
require "nokogiri"

def scrape_boekenbalie(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boekenbalie")

  slug = title.parameterize
  url = listing&.url || "https://boekenbalie.nl/#{slug}/#{isbn}"

  if listing&.url
    puts "Running previously fetched url Boekenbalie for: " + url
  else
    puts "Running new url for Boekenbalie for: " + url
  end

  document = get_document(url)

  price = document.css(".product-detail-price").first.text.strip.gsub(",", ".")
  image = document.css(".product-detail-media-gallery img").first.attribute("src").value.strip
  description = document.css(".js-product-detail-description-text").first.text.strip
  number_of_pages_label = document.at_css(".product-detail-properties-label:contains('Aantal pagina\'s')")
  number_of_pages = number_of_pages_label&.next_element&.text&.strip

  puts title
  puts isbn
  puts price
  puts image
  puts description
  puts number_of_pages

  { url: url, price: price, description: description, number_of_pages: number_of_pages }
end
