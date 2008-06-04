# A mailer to handle notifications for modifying your password.
class PasswordMailer < ActionMailer::Base
  include Login::MailConfig

  # Will send a message to the given user with the given link that
  # should lead them to a page to reset their password.
  def reset_password(user, reset_link)
    recipients user.email
    from system_email(reset_link)
    subject "#{subject_prefix}Forgotton Password"
    body :user => user, :reset_link => reset_link
  end

  # Will send a message to the given user to let me know their
  # password has been changed. It will include a link that will
  # allow them to reset their password in case they were not the ones
  # that changed it.
  def updated_password(user, reset_link)
    recipients user.email
    from system_email(reset_link)
    subject "#{subject_prefix}Password Updated"
    body :user => user, :reset_link => reset_link
  end
end