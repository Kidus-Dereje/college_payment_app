class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :service_name
      t.boolean :is_active

      t.timestamps
    end
    add_index :services, :service_name, unique: true
  end
end
