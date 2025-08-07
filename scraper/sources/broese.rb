require_relative "../get_document"

def scrape_broese(isbn)
  # Broese is weird and doesn't render any content on it's show pages during SSR, instead it's some Vue template.
  # The search pages however are totally fine. We get all data from the search results instead of using the actual url.
  # This means we have far less data available, but the most important bits are there, I suppose.

  # This user agent seems like the only one in base.rb that goes through, others get a 403
  headers = { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0" }
  base_url = 'https://www.broese.nl'

  document = get_document(base_url + "/zoek?q=#{isbn}", return_url: false, headers:)
  first_url = document&.at_css(".book .cover a")&.get_attribute("href")
  url = first_url.present? ? (base_url + first_url) : nil

  return { url: nil, available: false } if url.blank? || !document&.text&.include?(isbn)

  # Some prices are shown with a discount, which is right in the same element as the price itself.
  # We remove this discount text from the price text, rather than trying to select the regular price only.
  price = document.at_css(".book .price")&.text&.tr(",", ".").sub("vanaf", "")&.strip
  regular_price = document.at_css(".book .regular-price")&.text&.tr(",", ".")&.strip
  price = price.sub(regular_price, "")&.strip if regular_price.present?

  available = !(document.at_css(".book")&.text.include?("In winkelmand") || document.at_css(".book")&.text.include?("Reserveer nu"))

  { url:, price:, available:, condition: :new }
end
