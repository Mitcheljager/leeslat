require_relative "../config/environment"
require_relative "data/goodreads"
require_relative "get_book"
require_relative "attach_remote_image"

isbn = ARGV[0]

if isbn.present?
  puts "Finding and attaching image for #{isbn}..."

  book = get_book(isbn)
  data = get_goodreads_data(isbn)

  if data[:image_url].present?
    begin
      attach_remote_image(book, data[:image_url])
    rescue => error
      puts error
    end
  else
    puts "No valid image url was found for \"#{book.title}\" (#{isbn})"
  end
end
