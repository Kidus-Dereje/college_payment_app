class Api::V1::BankAccountsController < ApplicationController
  before_action :authenticate_user!
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
    Rails.logger.info "Bank account params: #{bank_account_params}"
    
    # Check if a bank account already exists for this service
    existing_bank_account = BankAccount.find_by(service_id: bank_account_params[:service_id])
    
    if existing_bank_account
      Rails.logger.info "Updating existing bank account: #{existing_bank_account.id}"
      # Update the existing bank account
      if existing_bank_account.update(bank_account_params)
        render json: existing_bank_account, status: :ok
      else
        Rails.logger.error "Update failed: #{existing_bank_account.errors.full_messages}"
        render json: {error: existing_bank_account.errors}, status: :unprocessable_entity
      end
    else
      Rails.logger.info "Creating new bank account"
      # Create a new bank account
      @bank_account = BankAccount.new(bank_account_params)

      if @bank_account.save
        render json: @bank_account, status: :created
      else
        Rails.logger.error "Create failed: #{@bank_account.errors.full_messages}"
        render json: {error: @bank_account.errors}, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error "Bank account create error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: {error: "Internal server error: #{e.message}"}, status: :internal_server_error
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
    permitted_params = params.require(:bank_account).permit(:bank_name, :account_number, :account_name, :service_id)
    # Convert service_id to integer if it's a string
    if permitted_params[:service_id].present?
      permitted_params[:service_id] = permitted_params[:service_id].to_i
    end
    permitted_params
  end
  def authenticate_admin!
    unless current_user&.admin?
      render json: {error: 'Only administrators can perform this action.'}, status: :forbidden
    end
  end
end
