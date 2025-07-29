class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :student_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.date :enrollment_date
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
    add_index :students, :student_id, unique: true
    add_index :students, :email, unique: true

  end
end
