require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module IntegrationTest
  class ContactMailsTest < ActionController::IntegrationTest
    
    def setup
      super
      @site = use_site! 'site with pages'
      @contact_mail = ContactMail.first
    end
    
    test "admin clicks through menu items of contact mails" do
      login_as_admin
      visit "/admin/sites/#{@site.id}/"
      
      click_link 'index_contact_mails'
      assert_template 'admin/contact_mails/index'
      
      # Goto show through subject link ...
      click_link "show_contact_mail_#{@contact_mail.id}"
      
      # .. to test the actual show menu item test
      click_link "show_contact_mail"
      assert_template 'admin/contact_mails/show'
      
      click_link "delete_contact_mail_#{@contact_mail.id}"
    end
  end
end