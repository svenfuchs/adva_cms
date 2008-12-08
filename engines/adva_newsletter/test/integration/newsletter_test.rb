require File.expand_path(File.join(File.dirname(__FILE__), '../../../adva_cms/test', 'test_helper' ))

class NoNewslettersTest < ActionController::IntegrationTest
  def setup
    Factory :site
    login_as :admin
  end
  
  test "admin submits a empty newsletter: should see warnings when doing it" do

    visit "/admin/sites/#{@site.id}/newsletters/new"

    assert_template 'admin/newsletters/new'
    fill_in :newsletter_title, :with => nil
    fill_in :newsletter_desc, :with => nil
    click_button 'Save'

    assert_template 'admin/newsletters/new'
    assert_select '.field_with_error'
  end

  test "admin visits index: should not have a list, should have link for creating a newsletter" do

    visit "/admin/sites/#{@site.id}/newsletters"
    
    assert_template 'admin/newsletters/index'
    assert_select '.empty'
    assert_select '.empty>a', 'Create a newsletter'
  end
  
  test "admin submits a new newsletter: should be sucsses" do

    visit "/admin/sites/#{@site.id}/newsletters"

    assert_template 'admin/newsletters'
    click_link "Create a newsletter"
    
    assert_template 'admin/newsletters/new'
    fill_in :newsletter_title, :with => 'newsletter title'
    fill_in :newsletter_desc, :with => 'newsletter desc'
    click_button 'Save'

    assert_template 'admin/newsletters/show'
    assert_select 'h1>a', 'newsletter title'
    assert_select 'p', 'newsletter desc'
  end
  
end


class NewslettersTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter
    login_as :admin
  end

  test "admin EDITS a new newsletter: should be success" do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}"
    
    assert_template 'admin/newsletters/show'
    click_link 'Edit'
    
    assert_template 'admin/newsletters/edit'
    fill_in :newsletter_title, :with => 'EDITED newsletter title'
    fill_in :newsletter_desc, :with => 'EDITED newsletter desc'
    click_button 'Save'

    assert_template 'admin/newsletters/show'
    assert cookies['flash'] =~ /Newsletter\+has\+been\+updated\+successfully/
    assert_select '#newsletter' do
      assert_select 'h1>a', 'EDITED newsletter title'
      assert_select 'p', 'EDITED newsletter desc'
    end
  end
end
