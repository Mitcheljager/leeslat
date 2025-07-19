require_relative "data/goodreads"
require "httparty"
require "tempfile"

isbn = ARGV[0]

puts "Finding and attaching image for #{isbn}..."

def attach_remote_image(book, url)
  response = HTTParty.get(url)

  if response.code == 200
    extension = File.extname(URI.parse(url).path.presence || ".jpg")

    file = Tempfile.new(["downloaded", File.extname(url)])
    file.binmode
    file.write(response.body)
    file.rewind

    book.public_send(:cover_image).attach(
      io: file,
      filename: "cover-#{book.isbn}#{extension}",
      content_type: response.headers["content-type"]
    )

    file.close
  else
    puts "Failed to fetch image: #{response.code}"
  end
end

book = get_book(isbn)
genres, format, image_url = get_goodreads_data(isbn)

if image_url.present?
  begin
    attach_remote_image(book, image_url)
    puts "Image successfully attached for \"#{book.title}\" (#{isbn})"
  rescue => error
    puts error
  end
else
  puts "No valid image url was found for \"#{book.title}\" (#{isbn})"
end

