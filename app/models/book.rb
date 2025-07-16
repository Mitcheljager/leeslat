class Book < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_many :book_authors
  has_many :authors, through: :book_authors

  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A[0-9]+\z/ }

  accepts_nested_attributes_for :book_authors, allow_destroy: true

  def to_param
    "#{title.parameterize}-#{isbn}"
  end
end
