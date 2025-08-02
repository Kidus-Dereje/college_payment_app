class Api::StudentsController < ApplicationController
  before_action :authenticate_user!

  def index
    students = Student.where(user_id: nil)
    render json: students
  end

  # POST /api/students/bulk_create_users
  def bulk_create_users
    student_ids = params[:student_ids]
    unless student_ids.is_a?(Array)
      return render json: { error: 'student_ids must be an array' }, status: :unprocessable_entity
    end
    service = BulkUserCreationService.new(student_ids).call
    render json: { created: service.created, errors: service.errors }, status: :ok
  end

end
