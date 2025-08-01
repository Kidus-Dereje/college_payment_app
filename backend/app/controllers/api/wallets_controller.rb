module Api
  class WalletsController < ApplicationController
    # GET /api/wallet/:user_id/balance
    def balance
      user = User.find_by(id: params[:user_id])
      if user && user.wallet
        render json: { balance: user.wallet.balance }, status: :ok
      else
        render json: { error: 'Wallet not found' }, status: :not_found
      end
    end
  end
end
