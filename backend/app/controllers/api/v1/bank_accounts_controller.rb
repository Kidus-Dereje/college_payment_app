class Api::V1::BankAccountsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_bank_account, only: [:show, :update, :destroy]

  def index
    @bank_accounts = BankAccount.all
    render json: @bank_accounts, status: :ok
  end

  def show
    render json: @bank_account, status: :ok
  end
  def create
    @bank_account = BankAccount.new(bank_account_params)

    if @bank_account.save
      render json: @bank_account, status: :created
    else
      render json: {error: @bank_account.errors}, status: :unprocessable_entity

    end
  end
  def update
    if @bank_account.update(bank_account_params)
      render json: @bank_account, status: :ok
    else
      render json: {errors: @bank_account.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    @bank_account.destroy
    head :no_content
  end


  private

  def set_bank_account
    @bank_account = BankAccount.find(params[:id])
  
  rescue ActiveRecord::RecordNotFound
    render json: {error: 'Bank account not found'}, status: :not_found
  end

  def bank_account_params
    params.require (:bank_account).permit(:bank_name, :account_number, :account_name, :service_id)
  end
  def authenticate_admin!
    unless current_user&.admin?
      render json: {error: 'Only administrators can perform this action.'}, status: :forbidden
    end
  end
end
