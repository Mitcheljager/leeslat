require_relative "base"

document = get_document("https://www.debestseller60.nl/")

isbn_list = []

document.css(".card__tags__tag").each do |tag|
  next unless tag.text.include?("ISBN")

  isbn_list << tag.text.gsub("ISBN", "").strip
end

isbn_list.each do |isbn|
  get_book(isbn)
end
