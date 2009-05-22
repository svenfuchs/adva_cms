require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
include Authentication::HashHelper

class ContactMailerCellTest < ActiveSupport::TestCase
  def setup
    super
    @controller   = CellTestController.new
    @cell         = ContactMailerCell.new(@controller)
  end
  
  test "#mailer_form sets the recipients from @opts[:recipients] and encrypts them" do
    @cell.instance_variable_set(:@opts, { "recipients" => 'user@test.com, another.user@test.com' })
    @cell.mailer_form
    @cell.instance_variable_get(:@recipients).should == encrypted_and_escaped('user@test.com, another.user@test.com')
  end
  
  test "#mailer_form sets the subjects from @opts[:subjects]" do
    @cell.instance_variable_set(:@opts, { "subject" => 'bug report' })
    @cell.mailer_form
    @cell.instance_variable_get(:@subject).should == 'bug report'
  end
  # FIXME test the cached_references
  # FIXME test the has_state option
  
  def encrypted_and_escaped(string)
     URI.escape(EzCrypto::Key.encrypt_with_password(ContactMail.password, send(:site_salt), string))
   end
end