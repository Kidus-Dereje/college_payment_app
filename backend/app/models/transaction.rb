class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :service
  belongs_to :wallet_transaction, optional: true
  belongs_to :bank_account, optional: true
  enum status: { pending: 0, completed: 1, failed: 2}

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :reference_id, presence: true, uniqueness: true
end
