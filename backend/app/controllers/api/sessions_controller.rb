class Api::SessionsController < ApplicationController
  # POST /api/login
  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      render json: { role: user.role, user_id: user.id }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  rescue => e
    Rails.logger.error "Login error: #{e.message}"
    render json: { error: 'An unexpected error occurred' }, status: :internal_server_error
  end
end