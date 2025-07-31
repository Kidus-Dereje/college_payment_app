class ChapaTransaction < ApplicationRecord
    belongs_to :user
    enum status: { pending: 0, completed: 1, failed: 2}

    validates :tx_ref,
            presence: true,
            uniqueness: true

    validates :amount,
            presence: true,
            numericality: { greater_than: 0 }
end
