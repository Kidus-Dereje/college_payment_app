class Student < ApplicationRecord
  belongs_to :user, optional: true
  has_many   :student_courses, dependent: :destroy
  has_many   :courses, through: :student_courses

  validates :student_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
