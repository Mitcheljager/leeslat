require_relative "data/goodreads"
require "httparty"
require "tempfile"

isbn = ARGV[0]

puts "Finding and attaching image for #{isbn}..."

def attach_remote_image(book, url)
  response = HTTParty.get(url)

  book.update(cover_last_scraped_at: DateTime.now)

  if response.code == 200
    file = Tempfile.new(["downloaded", File.extname(url)])
    file.binmode
    file.write(response.body)
    file.rewind

    # Get the image width and height, these are later used as an aspect ratio
    # to display the image correctly before it loads. Not all covers are the
    # same aspect ratio, after all.
    image = MiniMagick::Image.read(file)
    width = image.width
    height = image.height

    book.cover_original_width = width
    book.cover_original_height = height
    book.save

    file.rewind

    book.public_send(:cover_image).attach(
      io: file,
      filename: "cover-#{book.isbn}",
      content_type: response.headers["content-type"]
    )

    book.cover_image.analyze

    file.close
  else
    puts "Failed to fetch image: #{response.code}"
  end
end

book = get_book(isbn)
data = get_goodreads_data(isbn)

if data[:image_url].present?
  begin
    attach_remote_image(book, data[:image_url])
    puts "Image successfully attached for \"#{book.title}\" (#{isbn})"
  rescue => error
    puts error
  end
else
  puts "No valid image url was found for \"#{book.title}\" (#{isbn})"
end
