class WalletTransaction < ApplicationRecord
  belongs_to :wallet
  belongs_to :bank_account, optional: true

  enum direction: { credit: 0, debit: 1 }
  enum transaction_type: { wallet_topup: 0, service_payment: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :reference_id, presence: true, uniqueness: true
end
