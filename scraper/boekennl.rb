require_relative "base"
require "nokogiri"

def scrape_boekennl(isbn, title)
  slug = title.parameterize
  url = "https://boeken.nl/boeken/#{isbn}/#{slug}"

  puts "Running Boeken.nl for: " + url

  document = get_document(url)

  price = document.css(".product-info .uc-price").first.text.strip.gsub("€", "").gsub(",", ".")
  image = document.css(".group-cover-and-photos .field-name-field-cover img").first.attribute("data-src").value.strip

  puts price
  puts image

  save_result("Boeken.nl", isbn, price, "EUR", url)
end
