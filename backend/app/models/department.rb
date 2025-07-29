class Department < ApplicationRecord
    has_many :course_departments, dependent: :destroy
    has_many :courses, through: :course_departments
end
