require "httparty"
require "nokogiri"

response = HTTParty.get("https://boekenbalie.nl/a-line-to-kill/9781529124309", {
  headers: {
		"User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
	},
})

document = Nokogiri::HTML(response.body)

title = document.css("h1").text.strip
isbn = document.css(".product-detail-properties-value").first.text.strip
price = document.css(".product-detail-price").first.text.strip
image = document.css(".product-detail-media-gallery img").first.attribute("src").value.strip

puts title
puts isbn
puts price
puts image
