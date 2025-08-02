class StudentsController < ActionController::Base
  before_action :authenticate_user!

  # GET /students/email_preview
  def email_preview
    @created_users = session[:created_users] || []
    render 'email_preview'
  end

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
    redirect_to '/login', alert: 'Unauthorized'
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    header&.gsub('Bearer ', '')
  end
end
