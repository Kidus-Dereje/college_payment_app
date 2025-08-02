class ChangeTransactionTypeToIntegerInChapaTransactions < ActiveRecord::Migration[6.1]
  def change
    change_column :chapa_transactions, :transaction_type, :integer, using: 'transaction_type::integer'
  end
end
