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
    amount = params[:amount].to_d
    Rails.logger.info "Top-up request received: amount=#{amount}"
    return render json: { error: "Amount must be greater than zero" }, status: :unprocessable_entity if amount <= 0

    tx_ref = "topup-#{current_user.id}-#{SecureRandom.hex(8)}"

    chapa_tx = ChapaTransaction.create!(
      user: current_user,
      tx_ref: tx_ref,
      amount: amount,
      transaction_type: :wallet_topup,
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

    if chapa_response['status'] == 'success'
      render json: { checkout_url: chapa_response['data']['checkout_url'] }, status: :ok
    else
      render json: { error: chapa_response['message'] }, status: :unprocessable_entity
    end
  end

  def callback
    raw_body = request.body.read
    Rails.logger.debug "Raw request body: #{raw_body}"
    request.body.rewind

    chapa_response = JSON.parse(raw_body) rescue nil
    Rails.logger.debug "Parsed Chapa response: #{chapa_response.inspect}"

    unless chapa_response.is_a?(Hash) && chapa_response['data'].is_a?(Hash)
      Rails.logger.warn "Malformed or missing payload: #{chapa_response.inspect}"
      return head :bad_request
    end

    data = chapa_response['data']
    tx_ref = data['tx_ref']
    transaction_id = data['id']
    status = data['status']
    amount = data['amount'].to_d rescue 0

    Rails.logger.debug "tx_ref: #{tx_ref}, transaction_id: #{transaction_id}, status: #{status}, amount: #{amount}"

    chapa_tx = ChapaTransaction.find_by(tx_ref: tx_ref)
    return head :not_found unless chapa_tx

    user = chapa_tx.user
    return head :not_found unless user

    # Idempotency check
    if chapa_tx.chapa_status == "success" || Payment.exists?(transaction_id: transaction_id)
      Rails.logger.info "Duplicate callback: transaction already processed"
      return head :conflict
    end

    # Check Chapa status
    unless status == "success"
      chapa_tx.update(chapa_status: :failed, raw_payload: chapa_response)
      Rails.logger.warn "Callback status not successful for tx_ref: #{tx_ref}"
      return head :ok
    end

    # Begin atomic wallet credit
    ActiveRecord::Base.transaction do
      Payment.create!(
        user: user,
        amount: amount,
        status: :success,
        transaction_id: transaction_id,
        tx_ref: tx_ref,
        purpose: tx_ref.start_with?("topup") ? "topup" : "service"
      )

      if tx_ref.start_with?("topup")
        wallet = Wallet.find_or_create_by(user: user)

        wallet.with_lock do
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
        end

        Rails.logger.debug "Wallet updated: User #{user.id}, New balance: #{wallet.balance}"
      end

      chapa_tx.update(chapa_status: :success, raw_payload: chapa_response)

      AuditLog.create!(
        user: user,
        action: "chapa_callback_received",
        metadata: data
      )

      Rails.logger.info "Callback completed successfully for tx_ref: #{tx_ref}"
    end

    head :ok
  end

  private

  def payment_params
    params.require(:payment).permit(:service_id, :amount)
  end

  def callback_url
    "#{request.base_url}/api/v1/payments/callback"
  end
end