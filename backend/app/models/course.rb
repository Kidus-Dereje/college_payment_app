class Course < ApplicationRecord
    has_many :student_courses,    dependent: :destroy
    has_many :students, through: :student_courses
    has_many :course_departments, dependent: :destroy
    has_many :departments, through: :course_departments
end
