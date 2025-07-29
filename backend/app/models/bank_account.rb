class BankAccount < ApplicationRecord
  belongs_to :service
  has_many :wallet_transactions, dependent: :nullify
  has_many :payment_transactions, dependent: :nullify
  
  validates :bank_name, :account_number, :account_name, presence: true
  validates :account_number, uniqueness: true
end
