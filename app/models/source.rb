class Source < ApplicationRecord
  has_many :sources, dependent: :destroy

  has_one_attached :logo do |attachable|
    attachable.variant(:medium, resize_to_fill: [64, 64], quality: 95, format: :webp, preprocessed: true)
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :base_url, presence: true

  def to_param
    slug
  end
end
