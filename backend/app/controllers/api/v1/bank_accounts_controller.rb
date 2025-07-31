class Api::V1::BankAccountsController < ApplicationController

  private

  def bank_account_params
    params.require (:bank_account).permit(:bank_name, :account_number, :account_name, :service_id)
  end
end
