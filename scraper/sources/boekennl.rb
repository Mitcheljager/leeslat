require_relative "../base"
require "nokogiri"

def scrape_boekennl(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boeken.nl")

  # Boeken.nl removes certain stop words, they use Drupal with Pathauto. Only their list of English stop words is considered.
  # List from https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-modules/contributed-modules-for-managing-urls/pathauto-generate-url-path-aliases-automatically/per-language-strings-to-remove-suggestions
  stop_words = %w[a an as at before but by for from is in into like of off on onto per since than the this that to up via with]
  title_words = title.downcase.split
  filtered_words = title_words.reject { |word| stop_words.include?(word) }
  cleaned_title = filtered_words.join(" ")

  slug = cleaned_title.parameterize
  url = listing&.url || "https://boeken.nl/boeken/#{isbn}/#{slug}"

  puts "Running Boeken.nl for: " + url

  document = get_document(url)

  # Document was not an actual page, instead it fell back to some overview page
  # In this case we search and hope for the best
  if !document&.text&.include?("Beoordelingen")
    puts "No document found for Boeken.nl, searching instead..."

    url = "https://www.boeken.nl/zoeken?mefibs-form-search-data-keys=#{isbn}"
    document = get_document(url)

    return { url: nil, available: false } if url.blank? || document.blank?

    url = document.css("h3 a").first&.attribute("href").value
    document = get_document(url)
  end

  return { url: nil, available: false } if url.blank? || document.blank?

  price = document.css(".product-info .uc-price").first.text.gsub("€", "").gsub(",", ".").strip
  description = document.css(".field-name-body .nxte-shave-expanding-item").first&.text&.strip
  number_of_pages = document.css(".field-name-field-page-count .field-item").first&.text&.strip

  { url: url, price: price, description: description, number_of_pages: number_of_pages, available: !price.blank?, condition: :new }
end
