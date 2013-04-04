class NotificationMailer < ActionMailer::Base
  default :from => ENV['APPLICATION_FEEDBACK_FROM_EMAIL']
	layout 'mailer'

  ######### users

  def new_user(message)
    @message = message
    mail(:to => message.email, :subject => message.subject)
  end

  ######### file

  def new_file(message)
    @message = message
    mail(:bcc => message.bcc, :subject => message.subject)
  end

  ######### change vote

  def change_vote(message)
    @message = message
    mail(:bcc => message.bcc, :subject => message.subject)
  end



end
