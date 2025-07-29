class CreateWalletTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :wallet_transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.references :bank_account, null: true, foreign_key: true
      t.integer :transaction_type, null: false, default: 0
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.integer :direction, null: false, default: 0
      t.string :reference_id, null: false

      t.timestamps
    end

    # Indexes for performance & uniqueness
    add_index :wallet_transactions, :transaction_type
    add_index :wallet_transactions, :direction
    add_index :wallet_transactions, :reference_id, unique: true
  end
end
