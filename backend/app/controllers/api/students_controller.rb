class Api::StudentsController < ApplicationController
  before_action :authenticate_user!

  def index
    students = Student.where(user_id: nil)
    render json: students
  end

  # POST /api/students/bulk_create_users
  def bulk_create_users
    Rails.logger.info "Bulk create users called with student_ids: #{params[:student_ids]}"
    
    student_ids = params[:student_ids]
    unless student_ids.is_a?(Array)
      Rails.logger.error "student_ids is not an array: #{student_ids.class}"
      return render json: { error: 'student_ids must be an array' }, status: :unprocessable_entity
    end
    
    begin
      service = BulkUserCreationService.new(student_ids).call
      Rails.logger.info "Service completed. Created: #{service.created.length}, Errors: #{service.errors.length}"
      
      if service.created.any?
        # Store the created users data in session for email preview
        session[:created_users] = service.created
        Rails.logger.info "Stored #{service.created.length} users in session"
        render json: { 
          created: service.created, 
          errors: service.errors,
          redirect_url: "/students/email_preview"
        }, status: :ok
      else
        Rails.logger.info "No users created, returning error response"
        render json: { created: service.created, errors: service.errors }, status: :ok
      end
    rescue => e
      Rails.logger.error "Error in bulk_create_users: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: e.message }, status: :internal_server_error
    end
  end

end