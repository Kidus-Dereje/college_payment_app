class ChapaTransactionClean < ApplicationRecord
  enum chapa_status: { pending: 0, success: 1, failed: 2 }

  validates :tx_ref, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  belongs_to :user
end