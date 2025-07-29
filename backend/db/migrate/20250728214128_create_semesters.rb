class CreateSemesters < ActiveRecord::Migration[8.0]
  def change
    create_table :semesters do |t|
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
    add_index :semesters, :name, unique: true
  end
end
