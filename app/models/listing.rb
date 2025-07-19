class Listing < ApplicationRecord
  has_paper_trail

  belongs_to :book
  belongs_to :source

  enum :condition, [:unknown, :new, :used, :damaged], suffix: true

  validates :currency, inclusion: { in: %w[EUR USD GBP], message: "%{value} is not a valid currency" }, allow_nil: true
  validates :condition, inclusion: { in: Book.formats.keys }
end
