class BankAccount < ApplicationRecord
  belongs_to :service
  has_many :wallet_transactions, dependent: :nullify
  has_many :payment_transactions, dependent: :nullify
  
  validates :account_number, presence: true
  validates :account_number, uniqueness: true

  validates :service_id, uniqueness: {message: "has already been assigned a bank account"}
end
