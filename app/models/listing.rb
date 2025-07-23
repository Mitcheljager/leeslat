class Listing < ApplicationRecord
  has_paper_trail

  belongs_to :book
  belongs_to :source

  enum :condition, [:unknown, :new, :used, :damaged], suffix: true

  validates :currency, inclusion: { in: %w[EUR USD GBP], message: "%{value} is not a valid currency" }, allow_nil: true
  validates :condition, inclusion: { in: Listing.conditions.keys }

  def price_large
    price.to_s.split(".")[0]
  end

  def price_cents
    cents = price.to_s.split(".")[1]

    return cents + "0" if cents.size == 1
    cents
  end

  def price_label
    "€#{price_large},#{price_cents}"
  end

  def condition_label
    return "Nieuw" if new_condition?
    return "Tweedehands" if used_condition?
    return "Licht beschadigd" if damaged_condition?
    "Onbekend"
  end
end
