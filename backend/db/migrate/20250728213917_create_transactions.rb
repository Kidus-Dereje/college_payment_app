class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.references :wallet_transaction, null: true, foreign_key: true
      t.references :bank_account, null: true, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :status, null: false
      t.string :reference_id, null: false

      t.timestamps
    end
    # Removed add_index :transactions, :user_id because it is automatically created by t.references with foreign_key: true
    add_index :transactions, :status
    add_index :transactions, :reference_id, unique: true
  end
end
