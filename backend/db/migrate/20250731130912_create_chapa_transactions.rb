class CreateChapaTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :chapa_transactions do |t|
      t.string  :tx_ref,           null: false
      t.integer  :status,           null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.references :user,          null: false, foreign_key: true
      t.string  :transaction_type, null: false
      t.text    :raw_payload

      t.timestamps
    end

    add_index :chapa_transactions, :tx_ref, unique: true
  end
end
