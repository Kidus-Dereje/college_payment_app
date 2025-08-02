class ApplicationController < ActionController::API
  private

  def authenticate_user!
    token = extract_token_from_header
    if token
      payload = JwtService.decode(token)
      if payload
        @current_user = User.find_by(id: payload['user_id'])
        return if @current_user
      end
    end
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    header&.gsub('Bearer ', '')
  end
end
