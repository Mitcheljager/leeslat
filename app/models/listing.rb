class Listing < ApplicationRecord
  has_paper_trail

  belongs_to :book
  belongs_to :source

  enum :condition, [:unknown, :new, :used, :damaged], suffix: true

  validates :currency, inclusion: { in: %w[EUR USD GBP], message: "%{value} is not a valid currency" }, allow_nil: true
  validates :condition, inclusion: { in: Listing.conditions.keys }

  def price_large
    self.price.to_s.split(".")[0]
  end

  def price_cents
    self.price.to_s.split(".")[1]
  end
end
