class CourseDepartment < ApplicationRecord
  belongs_to :course
  belongs_to :department
end
