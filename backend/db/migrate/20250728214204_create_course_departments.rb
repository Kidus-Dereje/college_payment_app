class CreateCourseDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :course_departments do |t|
      t.references :course, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end
  end
end
