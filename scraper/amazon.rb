require_relative "base"
require "nokogiri"

document = get_document("https://www.amazon.nl/Het-bloemenmeisje-Anya-Niewierra/dp/9024593638")

title = document.css("h1 #productTitle").text.strip
isbn13 = document.css("[data-rpi-attribute-ref-tag='dbs_dp_rpi_r_d_book_details_isbn13'] .rpi-attribute-value").text.strip
price = document.css("#corePriceDisplay_desktop_feature_div .priceToPay").first.text.strip
image = document.css("#landingImage").first.attribute("src").value.strip

puts title
puts isbn13
puts price
puts image
