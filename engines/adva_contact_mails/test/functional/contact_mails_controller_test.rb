require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContactMailsControllerTest < ActionController::TestCase
  tests ContactMailsController
  
  with_common :a_site
  
  view :form do
    has_tag 'input[name=?]',    'contact_mail[email]'
    has_tag 'input[name=?]',    'contact_mail[subject]'
    has_tag 'textarea[name=?]', 'contact_mail[body]'
  end
  
  describe "routing" do
    with_options :path_prefix => '/' do |r|
      r.it_maps :get,  "contact_mails/new", :action => 'new'
      r.it_maps :post, "contact_mails",     :action => 'create'
    end
  end
  
  describe "GET to new" do
    action { get :new, default_params }
    
    it_assigns :contact_mail => ContactMail
    it_renders :template, :new
    
    has_form_posting_to contact_mails_path do
      shows :form
    end
  end
  
  describe "POST to create" do
    with "valid contact mail parameters" do
      action { post :create, valid_contact_mail_params.merge(:return_to => '/' ) }
  
      it_assigns :contact_mail => ContactMail
      it_assigns_flash_cookie :notice => :not_nil
      it_redirects_to { '/' }
    end
  
    with "invalid contact mail parameters" do
      action { post :create, invalid_contact_mail_params.merge(:return_to => '/' ) }
  
      it_assigns :contact_mail => ContactMail
      it_assigns_flash_cookie :error => :not_nil
      it_renders :template, :new
    end
  end
  
  def default_params
    { :site_id => @site.id }
  end

  def valid_contact_mail_params
    default_params.merge(:contact_mail => { :subject => 'Moi!', :body => 'Mites siellä menee?' } )
  end

  def invalid_contact_mail_params
    default_params.merge(:contact_mail => { :subject => 'Moi!', :body => '' } )
  end
end