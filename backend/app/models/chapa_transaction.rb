class ChapaTransaction < ApplicationRecord
  belongs_to :user

  # Status constants
  STATUS_PENDING = 0
  STATUS_SUCCESS = 1
  STATUS_FAILED  = 2

  TRANSACTION_TYPE_SERVICE     = 0
  TRANSACTION_TYPE_WALLET_TOPUP = 1

  validates :tx_ref, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [STATUS_PENDING, STATUS_SUCCESS, STATUS_FAILED] }
  validates :transaction_type, inclusion: { in: [TRANSACTION_TYPE_SERVICE, TRANSACTION_TYPE_WALLET_TOPUP] }

  # Helper methods
  def pending?
    status == STATUS_PENDING
  end

  def success?
    status == STATUS_SUCCESS
  end

  def failed?
    status == STATUS_FAILED
  end

  def service_transaction?
    transaction_type == TRANSACTION_TYPE_SERVICE
  end

  def wallet_topup_transaction?
    transaction_type == TRANSACTION_TYPE_WALLET_TOPUP
  end
end
