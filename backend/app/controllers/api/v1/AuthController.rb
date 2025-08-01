class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_admin!


  def login
    admin = Admin.find_by(email: params[:email], password: params[:password])
    student = Student.find_by(email: params[:email], password: params[:password])

    user = admin || student

    if user&.authenticate(params[:password])
      role = user. is_a?(Admin) ? 'admin' : 'student'
      token = JwtService.encode({ user_id: user.id, role: role})
      render json: {token: token, message: 'Login successful', role: role}, status: :ok
    else
      render json: {error: 'Invalid credentials'}, status: :unauthorized

    end
  

  end
end

