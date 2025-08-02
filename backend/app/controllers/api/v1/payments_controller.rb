class Api::V1::PaymentsController < ApplicationController
  # skip_before_action :authenticate_user_from_token!, only: [:callback]

  def create
    amount = payment_params[:amount].to_d
    service = Service.find_by(id: payment_params[:service_id])

    if service.nil?
      return render json: { error: "Service not found"}, status: :not_found
    end

    bank_account = service.bank_account
    if bank_account.nil?
      return render json: { error: "Service does not have an assigned bank account "}, status: :unprocessable_entity
    end

    tx_ref= "payment-#{current_user.id}-to-service-#{service.id}-#{SecureRandom.hex(8)}"

    chapa_tx = ChapaTransaction.create!(
      user: current_user,
      tx_ref: tx_ref,
      amount: amount,
      transaction_type: :service,
      status: :pending
    
    )

    chapa_payload={
      amount: amount,
      currency: "ETB",
      email: current_user.email,
      tx_ref: tx_ref,
      callback_url: "https://your-domain.com/api/v1/payments/callback",
      return_url: "https://your-frontend.com/payment-success"

    }
    chapa_response = ChapaService.initialize_payment(chapa_payload)
    chapa_tx.update(raw_payload: chapa_response)

    if chapa_response['status'] == "success"
      render json: {checkout_url: chapa_response['data']['checkout_url']}, status: :ok
    else
      render json: {error: chapa_response['message']}, status: :unprocessable_entity
    end
  end

  def top_up
    amount = params[:amount].to_d

    if amount <=0
      return render json: {error: "Amount must be greater than zero"}, status: :unprocessable_entity
    end
    tx_ref= "topup-#{current_user.id}-#{SecureRandom.hex(8)}"

    chapa_tx = ChapaTransaction.create!(
      user: current_user,
      tx_ref: tx_ref,
      amount: amount,
      transaction_type: "wallet_topup",
      status: :pending
    
    )

    chapa_payload={
      amount: amount,
      currency: "ETB",
      email: current_user.email,
      tx_ref: tx_ref,
      callback_url: "https://your-domain.com/api/v1/payments/callback",
      return_url: "https://your-frontend.com/payment-success"

    }
    chapa_response = ChapaService.initialize_payment(chapa_payload)
    chapa_tx.update(raw_payload: chapa_response)

    if chapa_response['status']=='success'
      render json: {checkout_url: chapa_response['data']['checkout_url']}, status: :ok
    else
      render json: {eror: chapa_response['message']}, status: :unprocessable_entity

    end
  end

  def callback
    

  raw_body = request.body.read
  Rails.logger.debug "Raw request body: #{raw_body}"
  request.body.rewind  

  # 🧠 Parse Chapa response
  chapa_response = JSON.parse(raw_body) rescue nil
  Rails.logger.debug "Parsed Chapa response: #{chapa_response.inspect}"

  # 🚨 Guard clause — validate basic structure
  unless chapa_response.is_a?(Hash) && chapa_response['data'].is_a?(Hash)
    Rails.logger.warn "Malformed or missing payload: #{chapa_response.inspect}"
    return head :bad_request
  end

  data = chapa_response['data']
  tx_ref = data['tx_ref']
  transaction_id = data['id']
  amount = data['amount'].to_d rescue 0

  # 🧪 Log important extracted values
  Rails.logger.debug "tx_ref: #{tx_ref}, transaction_id: #{transaction_id}, amount: #{amount}"

  # 🧮 Extract user_id from tx_ref (e.g., "topup-12-abc123")
  user_id = tx_ref.to_s.split('-')[1].to_i
  Rails.logger.debug "Extracted user_id: #{user_id}"

  # 🧍‍♂️ Find user
  user = User.find_by(id: user_id)
  return head :not_found unless user

  # 🧷 Prevent duplicate transaction
  return head :conflict if Payment.exists?(transaction_id: transaction_id)

  # 📥 Update ChapaTransaction record
  chapa_tx = ChapaTransaction.find_by(tx_ref: tx_ref)
  chapa_tx&.update(status: :success, raw_payload: chapa_response)

  # 💰 Create Payment record
  Payment.create!(
    user: user,
    amount: amount,
    status: :success,
    transaction_id: transaction_id,
    tx_ref: tx_ref,
    purpose: tx_ref.start_with?("topup") ? "topup" : "service"
  )

  # 🧱 Handle Wallet top-up flow
  if tx_ref.start_with?("topup")
    wallet = Wallet.find_or_create_by(user: user)

    WalletTransaction.create!(
      wallet: wallet,
      amount: amount,
      transaction_type: :credit,
      source: "Chapa",
      external_id: transaction_id,
      metadata: { tx_ref: tx_ref }
    )

    wallet.balance ||= 0
    wallet.balance += amount
    wallet.save!

    Rails.logger.debug "Wallet updated: User #{user.id}, New balance: #{wallet.balance}"
  end

 
  head :ok

  end
 
  private 
  def payment_params
    params.require(:payment).permit(:service_id, :amount)
  end


end
