# A mailer to send notications related to changes in a user profiles.
class AccountMailer < ActionMailer::Base
  include Login::MailConfig

  # Will send a message to the given user that will let the user
  # verify their email address. The verification_link argument is
  # the URL of the page that will receive the verification request.
  # The user should just have to click on the link.
  def signup_verification(user, verification_link)
    recipients user.email
    from system_email(verification_link)
    subject "#{subject_prefix}Email Verification"
    body :user => user, :verification_link => verification_link
  end

  # Will send a message to the given user so the user can re-activate
  # their deleted user account. The activation_link is the link that
  # will implement the actual reactivation when the user clicks.
  def reactivate_account(user, activation_link)
    recipients user.email
    from system_email(activation_link)
    subject "#{subject_prefix}Account Reactivation"
    body :user => user, :activation_link => activation_link
  end
end