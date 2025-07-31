class UserMailer < ApplicationMailer
  default from: 'no-reply@college.edu'

  def welcome_email
    @user = params[:user]
    @password = params[:password]
    @student = params[:student]
    mail(to: @user.email, subject: 'Your College Portal Credentials')
  end
end
