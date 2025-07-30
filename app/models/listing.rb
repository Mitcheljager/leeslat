class Listing < ApplicationRecord
  has_paper_trail

  belongs_to :book
  belongs_to :source

  enum :condition, [:unknown, :new, :used, :damaged], suffix: true

  validates :currency, inclusion: { in: VALID_CURRENCIES, message: "%{value} is not a valid currency" }, allow_nil: true
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

  def shipping_label
    # If the listing price includes shipping or if the price includes the sources free shipping cost threshold
    return "Gratis verzending" if price_includes_shipping? || (source.shipping_cost_free_from_price > 0 && price >= source.shipping_cost_free_from_price) || source.shipping_cost == 0
    "+€#{source.shipping_cost.to_s.gsub(".", ",")} verzenden"
  end

  def condition_label
    return "Nieuw" if new_condition?
    return "Tweedehands" if used_condition?
    return "Licht beschadigd" if damaged_condition?
    "Onbekend"
  end
end
