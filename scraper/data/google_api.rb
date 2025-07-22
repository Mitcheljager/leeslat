require "httparty"

def get_google_api_data(isbn)
  google_api_url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}&key=#{ENV["GOOGLE_CLOUD_API_KEY"]}"

  puts "Running Google API for: #{google_api_url}"

  book_data_response = HTTParty.get(google_api_url)
  parsed_response = JSON.parse(book_data_response.body)

  return if parsed_response["totalItems"] === 0 || parsed_response["items"].blank?

  item = parsed_response["items"][0]
  volume_info = item["volumeInfo"]
  sale_info = item["saleInfo"]

  is_ebook = sale_info["isEbook"] == true
  title = volume_info["title"]
  language = volume_info["language"]
  authors = volume_info["authors"]
  published_date = volume_info["publishedDate"]

  [is_ebook, title, language, authors, published_date]
end
