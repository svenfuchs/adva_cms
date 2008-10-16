# require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))
# 
# class UserVerificationTest < ActionController::IntegrationTest
#   
#   def test_user_does_verification
#     Factory :site_with_section
#     user = Factory(:unverified_user)
#     
#     visits 'user/verify'
#     
#     assert user.verified
#     # should have sent an email notification
#     # assert ActionMailer::Base.deliveries.any?, 'ActionMailer should have sent a notification'
#     # assert ActionMailer::Base.deliveries.first.to.include?(user.email)
#   end
#   
#   protected
# end
