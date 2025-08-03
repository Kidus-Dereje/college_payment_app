module V1
class Api::V1::PaymentsController < ApplicationController
  def current_user
    @current_user ||= User.first
  end

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
  # Log all received params
  Rails.logger.info "Params received in top_up: #{params.inspect}"
  Rails.logger.info "Current user email: #{current_user.email.inspect}"
  Rails.logger.info "Current user email: #{current_user.email.inspect}"

  unless current_user&.email&.match?(URI::MailTo::EMAIL_REGEXP)
    Rails.logger.warn "Invalid email: #{current_user.email.inspect}"
    return render json: { error: "Invalid user email for payment" }, status: :unprocessable_entity
  end




  # Safely parse amount
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
  chapa_response = params.require(:payment).permit(
    :tx_ref, :amount, :status, :transaction_id, :customer_email
  )

  puts "Parsed Chapa response: #{chapa_response.inspect}"
  tx_ref = chapa_response[:tx_ref]
  transaction_id = chapa_response[:transaction_id]
  status = chapa_response[:status]
  amount = chapa_response[:amount].to_f

  puts "tx_ref: #{tx_ref}, transaction_id: #{transaction_id}, status: #{status}, amount: #{amount}"

  chapa_tx = ChapaTransaction.find_by(tx_ref: tx_ref)
  if chapa_tx.nil?
    puts "Transaction not found for tx_ref: #{tx_ref}"
    render json: { error: "Transaction not found" }, status: :not_found
    return
  end

  user = chapa_tx.user
  if chapa_tx.success?
    puts "Transaction already marked successful."
    render json: { message: "Already processed" }, status: :ok
    return
  end
  if chapa_tx.status != "success"
  ActiveRecord::Base.transaction do
    chapa_tx.update!(status: ChapaTransaction::STATUS_SUCCESS)
    user.wallet.increment!(:balance, amount)
  end
  end


  if status == "success"
  ActiveRecord::Base.transaction do
    chapa_tx.update!(status: ChapaTransaction::STATUS_SUCCESS)

    if user.wallet
      user.wallet.increment!(:balance, amount)  # Safely increment wallet balance
      Rails.logger.debug "Wallet credited: #{amount} ETB → User #{user.id}"
    else
      Rails.logger.error "Wallet not found for user ##{user.id}"
      render json: { error: "User wallet not found" }, status: :unprocessable_entity
      return
    end
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