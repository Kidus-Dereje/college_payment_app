class Removechapastatusfromchapatransaction < ActiveRecord::Migration[8.0]
  def change
    remove_column :chapa_transactions, :chapa_status, :integer
  end
end
