require_relative "base"

isbn_list = []

document = get_document("https://www.debestseller60.nl/")
document.css(".card__tags__tag").each do |node|
  next unless node.text.include?("ISBN")

  isbn = node.text.gsub("ISBN", "").strip
  isbn_list << isbn if isbn.present?
end

document = get_document("https://www.boeken.nl/boeken/top-100?mefibs-form-view-options-top-keys=&mefibs-form-view-options-top-items_per_page=100&mefibs-form-view-options-top-mefibs_block_id=view_options_top")
document.css(".views-row a").each do |node|
  url = node.attribute("href").value

  next if url.blank?

  isbn = url.match(%r{/(\d{10,13})/})&.captures&.first

  next if isbn.blank?
  next if isbn_list.include?(isbn)

  puts "Adding: #{isbn}"

  isbn_list << isbn
end

isbn_list.each do |isbn|
  get_book(isbn)
end
