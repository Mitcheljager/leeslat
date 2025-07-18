class Book < ApplicationRecord
  include ActionView::Helpers::NumberHelper

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
  validates :language, inclusion: { in: Book.languages.keys }, allow_nil: true
  validates :format, inclusion: { in: Book.formats.keys }

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

    return self.formatted_published_date if self.published_date_text.length === 4 # It's probably a year

    parts = self.published_date_text.split("-").map(&:to_i)
    I18n.l(Date.new(parts[0], parts[1], parts[2]), format: "%-d %B, %Y")
  end
end
