class CreateTuitionFees < ActiveRecord::Migration[8.0]
  def change
    create_table :tuition_fees do |t|
      t.decimal :amount_per_credit, precision: 8, scale: 2
      t.date :enrollment_date

      t.timestamps
    end
  end
end
