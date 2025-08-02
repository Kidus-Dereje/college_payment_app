require 'rails_helper'

RSpec.describe "PaymentsCallback", type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  let(:valid_payload) do
    {
      data: {
        tx_ref: "topup-123",
        id: "chapa_tx_001",
        amount: 100,
        status: "success"
      }
    }.to_json
  end

  it "creates a payment and credits wallet" do
    post "/api/v1/payments/callback", params: valid_payload, headers: headers

    expect(response).to have_http_status(:ok)
    expect(Payment.find_by(transaction_id: "chapa_tx_001")).to be_present
    expect(WalletTransaction.find_by(external_id: "chapa_tx_001")).to be_present
  end
end