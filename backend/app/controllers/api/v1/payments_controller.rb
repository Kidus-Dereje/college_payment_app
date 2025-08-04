module V1
class Api::V1::PaymentsController < ApplicationController
  before_action :authenticate_user!
  # def current_user
  #   @current_user ||= User.first
  # end

  def create
    amount = payment_params[:amount].to_d
    service = Service.find_by(id: payment_params[:service_id])

    return render json: { error: "Service not found" }, status: :not_found if service.nil?

    bank_account = service.bank_account
    return render json: { error: "Service does not have an assigned bank account" }, status: :unprocessable_entity if bank_account.nil?

    tx_ref = "payment-#{current_user.id}-to-service-#{service.id}-#{SecureRandom.hex(8)}"

    chapa_tx = ChapaTransaction.create!(
      user: current_user,
      tx_ref: tx_ref,
      amount: amount,
      transaction_type: :service,
      chapa_status: :pending
    )

    chapa_payload = {
      amount: amount,
      currency: "ETB",
      email: current_user.email,
      tx_ref: tx_ref,
      callback_url: callback_url,
      return_url: "https://your-frontend.com/payment-success"
    }

    chapa_response = ChapaService.initialize_payment(chapa_payload)
    chapa_tx.update(raw_payload: chapa_response)

    if chapa_response['status'] == "success"
      render json: { checkout_url: chapa_response['data']['checkout_url'] }, status: :ok
    else
      render json: { error: chapa_response['message'] }, status: :unprocessable_entity
    end
  end

  def top_up
  
  Rails.logger.info "Params received in top_up: #{params.inspect}"
  Rails.logger.info "Current user email: #{current_user.email.inspect}"
  

  unless current_user&.email&.match?(URI::MailTo::EMAIL_REGEXP)
    Rails.logger.warn "Invalid email: #{current_user.email.inspect}"
    return render json: { error: "Invalid user email for payment" }, status: :unprocessable_entity
  end




  
  begin
    amount = params[:amount].to_d
  rescue
    return render json: { error: "Invalid or missing amount" }, status: :unprocessable_entity
  end

  if amount <= 0
    return render json: { error: "Amount must be greater than zero" }, status: :unprocessable_entity
  end

  tx_ref = "topup-#{current_user.id}-#{SecureRandom.hex(8)}"
  Rails.logger.info "Generated tx_ref: #{tx_ref} for amount: #{amount}"

  chapa_tx = ChapaTransaction.create!(
  user: current_user,
  tx_ref: tx_ref,
  amount: amount,
  transaction_type: ChapaTransaction::TRANSACTION_TYPE_WALLET_TOPUP,
  status: ChapaTransaction::STATUS_PENDING
)


  chapa_payload = {
    amount: amount.to_s,  # Chapa expects amount as string
    currency: "ETB",
    email: current_user.email,
    tx_ref: tx_ref,
    callback_url: api_v1_payments_callback_url(host: "localhost", port: 3000),
    return_url: "https://your-frontend.com/payment-success",
    customization: {
      title: "Wallet Top-Up",
      description: "Add funds to your wallet"
    }
  }

  Rails.logger.info "Sending to Chapa: #{chapa_payload.to_json}"

  chapa_response = ChapaService.initialize_payment(chapa_payload)
  chapa_tx.update(raw_payload: chapa_response)

  if chapa_response['status'] == 'success'
    render json: { checkout_url: chapa_response['data']['checkout_url'], tx_ref: tx_ref }, status: :ok
  else
    error_message = chapa_response['message'] || "Unknown error from payment gateway"
    Rails.logger.warn("Chapa payment failed: #{error_message}")
    render json: { error: error_message }, status: :unprocessable_entity
  end
  end

def callback
  chapa_response = params.permit(:tx_ref, :amount, :status, :transaction_id, :customer_email)

  tx_ref = chapa_response[:tx_ref]
  amount = chapa_response[:amount].to_f
  status = chapa_response[:status]

  Rails.logger.info "Callback received: tx_ref=#{tx_ref}, status=#{status}, amount=#{amount}"

  chapa_tx = ChapaTransaction.find_by(tx_ref: tx_ref)
  unless chapa_tx
    Rails.logger.error "Transaction not found for tx_ref: #{tx_ref}"
    return render json: { error: "Transaction not found" }, status: :not_found
  end

  user = chapa_tx.user
  unless user.wallet
    Rails.logger.error "Wallet not found for user ##{user.id}"
    return render json: { error: "User wallet not found" }, status: :unprocessable_entity
  end

  if chapa_tx.success?
    Rails.logger.info "Transaction already marked successful."
    return render json: { message: "Already processed" }, status: :ok
  end

  if status == "success"
    ActiveRecord::Base.transaction do
      chapa_tx.update!(status: ChapaTransaction::STATUS_SUCCESS)
      user.wallet.increment!(:balance, amount)
      Rails.logger.debug "Wallet credited: #{amount} ETB → User #{user.id}"
    end
  else
    chapa_tx.update!(status: ChapaTransaction::STATUS_FAILED)
    Rails.logger.warn "Transaction failed for tx_ref: #{tx_ref}"
  end

  render json: { message: "Callback handled" }, status: :ok
end




  private

  def payment_params
    params.require(:payment).permit(:service_id, :amount)
  end

  def callback_url
    "#{request.base_url}/api/v1/payments/callback"
  end
end
end