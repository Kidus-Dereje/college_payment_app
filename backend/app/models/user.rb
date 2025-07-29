class User < ApplicationRecord
    enum role: { student: 0, admin: 1}
    has_secure_password
    has_one  :student,        dependent: :destroy
    has_one  :wallet,         dependent: :destroy
    has_many :transactions,   dependent: :destroy
end
