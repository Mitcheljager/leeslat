require_relative "base"
require "nokogiri"

document = get_document("https://boekenbalie.nl/a-line-to-kill/9781529124309")

title = document.css("h1").text.strip
isbn = document.css(".product-detail-properties-value").first.text.strip
price = document.css(".product-detail-price").first.text.strip
image = document.css(".product-detail-media-gallery img").first.attribute("src").value.strip

puts title
puts isbn
puts price
puts image
