class RequestedISBN < ApplicationRecord
  enum :status, [:not_found, :error, :rejected, :resolved]

  validates :statuses, inclusion: { in: RequestedISBN.status.keys }
end
