class Source < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :base_url, presence: true, uniqueness: true
end
