class AddChapaStatusToChapaTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :chapa_transactions, :chapa_status, :integer, default: 0
  end
end
