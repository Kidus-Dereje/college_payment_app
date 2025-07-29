class Service < ApplicationRecord
    has_many :transactions
    has_one :bank_account, dependent: :destroy
    validates :service_name, presence: true
end
