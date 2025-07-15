class Listing < ApplicationRecord
  belongs_to :book
  belongs_to :source

  validates :price, presence: true
  validates :currency, presence: true, inclusion: { in: %w[EUR USD GBP], message: "%{value} is not a valid currency" }
  validates :url, presence: true
end
