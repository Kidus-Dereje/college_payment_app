class BulkUserCreationService
  # Accepts an array of student ids
  def initialize(student_ids)
    @student_ids = student_ids
    @created = []
    @errors = []
  end

  attr_reader :created, :errors

  def call
    students = Student.where(student_id: @student_ids, user_id: nil)
    Rails.logger.info "Found #{students.count} students to process"
    
    students.find_each do |student|
      Rails.logger.info "Processing student: #{student.student_id}"
      
      begin
        password = SecureRandom.hex(8)
        user = User.new(email: student.email, password: password, role: "student")
        
        if user.save
          Rails.logger.info "User created successfully for student #{student.student_id}"
          student.update(user_id: user.id)
          
          # Send email
          begin
            UserMailer.with(user: user, password: password, student: student).welcome_email.deliver_later
            Rails.logger.info "Email queued for student #{student.student_id}"
          rescue => e
            Rails.logger.error "Email error for student #{student.student_id}: #{e.message}"
          end
          
          @created << {student_id: student.student_id, user_id: user.id, email: student.email, password: password}
        else
          Rails.logger.error "User creation failed for student #{student.student_id}: #{user.errors.full_messages}"
          @errors << {student_id: student.student_id, errors: user.errors.full_messages}
        end
      rescue => e
        Rails.logger.error "Error processing student #{student.student_id}: #{e.message}"
        @errors << {student_id: student.student_id, errors: [e.message]}
      end
    end
    
    Rails.logger.info "BulkUserCreationService completed. Created: #{@created.length}, Errors: #{@errors.length}"
    self
  end

  private

  def generate_unique_email
    loop do
      email = "student_#{SecureRandom.hex(5)}@example.com"
      break email unless User.exists?(email: email)
    end
  end
end
