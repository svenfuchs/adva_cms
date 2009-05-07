require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContactMailTest < ActiveSupport::TestCase
  def setup
    super
    @contact_mail = ContactMail.new
  end
  
  # Associations
  
  test "belongs to site" do
    @contact_mail.should belong_to(:site)
  end
  
  test "site has many contact mails" do
    Site.first.should have_many(:contact_mails)
  end
  
  # Validations
  
  test "validates the presence of subject" do
    @contact_mail.should validate_presence_of(:subject)
  end
  
  test "validates the presence of body" do
    @contact_mail.should validate_presence_of(:body)
  end
end