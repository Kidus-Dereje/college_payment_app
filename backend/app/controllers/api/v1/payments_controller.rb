class Api::V1::PaymentsController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:callback]

  def create
    amount = payment_params[:amount].to_d
    service = Service.find_by(id :payment_params[:service_id])

    if service.nil?
      return render json: { error: "Service not found"}, status: :not_found
    end

    bank_account = service.bank_account
    if bank_account.nil?
      return render json: { error: "Service does not have an assigned bank account "}, status: :unprocessable_entity
    end

    tx_ref= "payment-#{current_user.id}-to-service-#{service.id}-#{SecureRandom.hex(8)}"

    chapa_payload={
      amount: amount,
      currency: "ETB",
      email: current_user.email,
      tx_ref: tx_ref,
      callback_url: "https://your-domain.com/api/v1/payments/callback",
      return_url: "https://your-frontend.com/payment-success"

    }
    chapa_response = ChapaService.initialize_payment(chapa_payload)

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

    chapa_payload={
      amount: amount,
      currency: "ETB",
      email: current_user.email,
      tx_ref: tx_ref,
      callback_url: "https://your-domain.com/api/v1/payments/callback",
      return_url: "https://your-frontend.com/payment-success"

    }
    chapa_response = ChapaService.initialize_payment(chapa_payload)

    if chapa_response['status']=='success'
      render json: {checkout_url: chapa_response['data']['checkout_url']}, status: :ok
    else
      render json: {eror: chapa_response['message']}, status: :unprocessable_entity

    end
  end

  def callback
    chapa_response= ChapaService.verfiy_payment(params[:tx_ref])

    if chapa_response['status'] == "success"
      user_id = chapa_response['data']['tx_ref'].split('-')[1].to_i
      user = User.find_by(id: user_id)

      if user
        amount = chapa_response['data']['amount']. to_d
        user.balance+= amount
        user.save!

        paymnet.create!(user:user, amount: amount, status: :success, transaction_id: chapa_response['data']['id'])

      end
    end
    head :ok
  end
  private 
  def payment_params
    params.require(:payment).permit(:service_id, :amount)
  end


end
