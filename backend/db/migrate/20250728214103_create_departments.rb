class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :department_id
      t.string :department_name

      t.timestamps
    end
    add_index :departments, :department_id, unique: true
  end
end
