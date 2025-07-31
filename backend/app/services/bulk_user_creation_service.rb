class BulkUserCreationService
  # Accepts an array of student ids
  def initialize(student_ids)
    @student_ids = student_ids
    @created = []
    @errors = []
  end

  attr_reader :created, :errors

  def call
    students = Student.where(id: @student_ids, user_id: nil)
    students.find_each do |student|
      password = SecureRandom.hex(8)
      user = User.new(email: student.email, password: password, role: "student")
      if user.save
        student.update(user_id: user.id)
        UserMailer.with(user: user, password: password, student: student).welcome_email.deliver_later
        @created << {student_id: student.id, user_id: user.id, email: student.email}
      else
        @errors << {student_id: student.id, errors: user.errors.full_messages}
      end
    end
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
