class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :course_id
      t.string :course_name
      t.integer :credits

      t.timestamps
    end
    add_index :courses, :course_id, unique: true
  end
end
