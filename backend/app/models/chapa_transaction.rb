class ChapaTransaction < ApplicationRecord
  belongs_to :user

  # Constants for chapa_status
  CHAPA_STATUS_PENDING = 0
  CHAPA_STATUS_SUCCESS = 1
  CHAPA_STATUS_FAILED  = 2

  # Constants for transaction_type
  TRANSACTION_TYPE_SERVICE     = 0
  TRANSACTION_TYPE_WALLET_TOPUP = 1

  validates :tx_ref, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  validates :chapa_status, inclusion: { in: [CHAPA_STATUS_PENDING, CHAPA_STATUS_SUCCESS, CHAPA_STATUS_FAILED] }
  validates :transaction_type, inclusion: { in: [TRANSACTION_TYPE_SERVICE, TRANSACTION_TYPE_WALLET_TOPUP] }

  # Helper methods for convenience
  def pending?
    chapa_status == CHAPA_STATUS_PENDING
  end

  def success?
    chapa_status == CHAPA_STATUS_SUCCESS
  end

  def failed?
    chapa_status == CHAPA_STATUS_FAILED
  end

  def service_transaction?
    transaction_type == TRANSACTION_TYPE_SERVICE
  end

  def wallet_topup_transaction?
    transaction_type == TRANSACTION_TYPE_WALLET_TOPUP
  end
end
