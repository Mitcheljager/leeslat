class User < ApplicationRecord
  has_secure_password

  has_many :remember_tokens, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[\p{L}\d_-]*\z/u }, length: { maximum: 32 }
  validates :password, presence: true, length: { minimum: 8 }
end
