class Book < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors

  enum :format, [:unknown, :paperback, :hardcover], suffix: true
  enum :language, { dutch: "nl", english: "en" }

  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A[0-9]+\z/ }
  validates :language, inclusion: { in: Book.languages.keys }
  validates :format, inclusion: { in: Book.formats.keys }

  accepts_nested_attributes_for :book_authors, allow_destroy: true

  def to_param
    "#{title.parameterize}-#{isbn}"
  end
end
