class CreateBankAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.references :service, null: false, foreign_key: true
      t.string :bank_name, null: false
      t.string :account_number, null: false
      t.string :account_name, null: false

      t.timestamps
    end

    add_index :bank_accounts, :account_number, unique: true
  end
end
