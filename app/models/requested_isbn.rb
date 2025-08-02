class RequestedISBN < ApplicationRecord
  enum :status, [:not_found, :error, :rejected, :resolved]

  validates :status, inclusion: { in: RequestedISBN.status.keys }
end
