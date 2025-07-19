class Book < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1 }

  has_many :listings, dependent: :destroy
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres

  has_one_attached :cover_image do |attachable|
    attachable.variant :large, resize_to_limit: [600, 600], preprocessed: true
    attachable.variant :small, resize_to_limit: [200, 200], preprocessed: true
    attachable.variant :tiny,  resize_to_limit: [100, 100], preprocessed: true
  end

  enum :format, [:unknown, :paperback, :hardcover], suffix: true
  enum :language, { dutch: "nl", english: "en" }

  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A[0-9]+\z/ }
  validates :format, inclusion: { in: Book.formats.keys }
  validates :language, inclusion: { in: Book.languages.keys }, allow_nil: true
  validates :published_date_text, format: { with: /\A[0-9\-]+\z/ }, allow_nil: true, allow_blank: true

  accepts_nested_attributes_for :book_authors, allow_destroy: true
  accepts_nested_attributes_for :book_genres, allow_destroy: true

  def to_param
    "#{title.parameterize}-#{isbn}"
  end

  def listings_with_price
    listings.where.not(price: 0)
  end

  def formatted_number_of_pages
    self.number_of_pages.zero? ? "-" : number_with_delimiter(self.number_of_pages, delimiter: ".")
  end

  def formatted_published_date
    return if self.published_date_text.blank?

    return self.published_date_text if self.published_date_text.length === 4 # It's probably a year

    parts = self.published_date_text.split("-").map(&:to_i)
    I18n.l(Date.new(parts[0], parts[1], parts[2]), format: "%-d %B, %Y")
  end

  def self.search(query, size: 50)
    is_isbn = query.match?(/\A\d{13}?\z/)

    __elasticsearch__.search({
      from: 0,
      size: size,
      query: {
        bool: {
          should: [
            (is_isbn ? { term: { isbn: query } } : nil),
            {
              multi_match: {
                query: query,
                fields: [
                  "title^4",
                  "authors^3",
                  "genres^2",
                  "genre_keywords"
                ],
                type: "cross_fields",
                operator: "and",
                tie_breaker: 0.1,
                boost: 100,
                minimum_should_match: "50%"
              }
            },
            {
              function_score: {
                query: {
                  multi_match: {
                    query: query,
                    fields: [
                      "title^3",
                      "authors^2.5",
                      "genres^1.5",
                      "genre_keywords"
                    ],
                    fuzziness: "AUTO"
                  }
                },
                boost_mode: "sum",
                max_boost: 2
              }
            }
          ].compact
        }
      }
    }).records
  end

  def as_indexed_json(_options = {})
    {
      isbn: isbn,
      title: title,
      authors: authors.map(&:name),
      genres: genres.map(&:name),
      genre_keywords: genres.flat_map { |g| g.keywords.to_s.split(',').map(&:strip) }
    }
  end
end
