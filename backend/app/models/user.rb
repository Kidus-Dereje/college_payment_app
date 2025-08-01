class User < ApplicationRecord
  has_secure_password

  enum :role, { student: 0, admin: 1 }

  has_one :student, dependent: :destroy
  has_one :wallet, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  after_create :create_wallet_for_student

  private

  def create_wallet_for_student
    if student?
      create_wallet(balance: 0)
    end
  end
end