require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST #chapa' do
    let(:user) { create(:user) }
    let(:wallet) { create(:wallet, user: user, balance: 0.0) }

    before { wallet } # Ensure wallet exists

    it 'credits wallet and logs transaction when verification passes' do
      allow(controller).to receive(:verify_chapa_transaction).and_return({
        "status" => "success",
        "data" => {
          "tx_ref" => "TOPUP-TEST-001",
          "amount" => "300.0",
          "currency" => "ETB"
        }
      })

      post :chapa, params: {
        status: "success",
        tx_ref: "TOPUP-TEST-001",
        transaction_id: "CHAPA-TX-TEST-001",
        amount: "300.0",
        currency: "ETB",
        user_id: user.id
      }

      expect(response).to have_http_status(:ok)
      expect(wallet.reload.balance).to eq(300.0)
      expect(WalletTransaction.find_by(reference_id: "TOPUP-TEST-001")).not_to be_nil


    end
    it 'does not credit wallet if tx_ref was already processed' do
      WalletTransaction.create!(
        wallet: wallet,
        tranasaction_type: :topup,
        direction: :inbound,
        amount: 300.0,
        reference_id: "TOPUP-TEST-001",
        bank_account: nil
      )
      allow(controller).to receive(:verify_chapa_transaction).and_return({
        "status" => "success",
        "data" => {
          "tx_ref" => "TOPUP-TEST-001",
          "amount" => "300.0",
          "currency" => "ETB"
        }
      })
      post :chapa, params: {
        status: "success",
        tx_ref: "TOPUP-TEST-001",
        transaction_id: "CHAPA-TX-TEST-001",
        amount: "300.0",
        currency: "ETB",
        user_id: user.id
      }
      expect(response).to have_http_status(:ok)
      expect(wallet.reload.balance).to eq(0.0)
      expect(WalletTransaction.where(reference_id: "TOPUP-TEST-001").count).to eq(1)
    end
    it 'does not credit wallet if chapa verification fails' do
      chapa_tx = ChapaTransaction.create!(
        user: user,
        tx_ref: "TOPUP-TEST-002",
        amount: 500.0,
        chapa_status: ChapaTransaction::CHAPA_STATUS_PENDING,
        transaction_type: ChapaTransaction::TRANSACTION_TYPE_WALLET_TOPUP
      )
      allow(controller).to receive(:verify_chapa_transaction).and_return({
        "status" => "success",
        "data"=>{
          "tx_ref" => "TOPUP-TEST-002",
          "amount" => "9999.99",
          "currency"=> "ETB"
        }
    })
      post :chapa, params: {
        status: "success",
        tx_ref: "TOPUP-TEST-002",
        transaction_id: "CHAPA-TX-TEST-002",
        amount: "300.0",
        currency: "ETB",
        user_id: user.id
     }
     chapa_tx.reload

     expect(response).to have_http_status(:bad_request)
     expect(wallet.reload.balance).to eq(0.0)

     expect(WalletTransaction.find_by(reference_id: "TOPUP-TEST-002")).to be_nil

     expect(chapa_tx.chapa_status).to eq(ChapaTransaction::CHAPA_STATUS_PENDING)
    end
    end
end
