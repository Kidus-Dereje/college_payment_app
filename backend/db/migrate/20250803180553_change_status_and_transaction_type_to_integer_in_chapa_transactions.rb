class ChangeStatusAndTransactionTypeToIntegerInChapaTransactions < ActiveRecord::Migration[8.0]
  def change
    change_column :chapa_transactions, :status, :integer, null: false
    change_column :chapa_transactions, :transaction_type, :integer, null: false
  end
end
