require_relative "base"
require "nokogiri"

def scrape_boekenbalie(isbn, title)
  slug = title.parameterize
  document = get_document("https://boekenbalie.nl/#{slug}/#{isbn}")

  title = document.css("h1").text.strip
  isbn = document.css(".product-detail-properties-value").first.text.strip
  price = document.css(".product-detail-price").first.text.strip.gsub(",", ".")
  image = document.css(".product-detail-media-gallery img").first.attribute("src").value.strip

  puts title
  puts isbn
  puts price
  puts image

  save_result("Boekenbalie", isbn, title, "author", price, "EUR", "some-url")
end
