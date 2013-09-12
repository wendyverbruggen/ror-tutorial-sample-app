class UserMailer < ActionMailer::Base
  default from: 'info@swrve.com'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome!")
  end
end
