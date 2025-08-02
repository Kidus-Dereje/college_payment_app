require 'net/http'
require 'uri'
require 'json'

class WebhooksController < ApplicationController
  # Skip CSRF protection for external webhook
  # skip_before_action :verify_authenticity_token

  def chapa
    payload = params.permit(:status, :tx_ref, :transaction_id, :amount, :currency, :user_id)

    verification = verify_chapa_transaction(payload[:transaction_id])
    unless verified?(payload, verification)
      Rails.logger.warn "⚠️ Webhook verification failed: #{payload[:tx_ref]}"
      return head :bad_request
    end

    Rails.logger.info "✅ Webhook verified: #{payload[:tx_ref]}"
    Rails.logger.info "📩 Raw Payload: #{request.raw_post}"

    # 🛡️ Replay protection
    if WalletTransaction.exists?(reference_id: payload[:tx_ref])
      Rails.logger.info "⏪ Skipping already processed tx_ref: #{payload[:tx_ref]}"
      return head :ok
    end

    user = User.find_by(id: payload[:user_id])
    return head :not_found unless user

    ActiveRecord::Base.transaction do
      # 💰 Credit wallet
      user.wallet.increment!(:balance, payload[:amount].to_f)

      # 📝 Log transaction
      WalletTransaction.create!(
        wallet: user.wallet,
        bank_account: nil, # optional if direct Chapa topup
        transaction_type: :topup, # use enum if defined
        direction: :inbound,      # use enum if defined
        amount: payload[:amount],
        reference_id: payload[:tx_ref]
      )
    end

    head :ok
  end

  private

  def verify_chapa_transaction(transaction_id)
    uri = URI("https://api.chapa.co/v1/transaction/verify/#{transaction_id}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV['CHAPA_SECRET_KEY']}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "Verification request failed: #{e.message}"
    {}
  end

  def verified?(payload, verification)
    verification["status"] == "success" &&
    verification["data"]["tx_ref"] == payload[:tx_ref] &&
    verification["data"]["amount"].to_f == payload[:amount].to_f &&
    verification["data"]["currency"] == payload[:currency]
  end
end