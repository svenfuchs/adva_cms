require File.expand_path(File.join(File.dirname(__FILE__), '../../../adva_cms/test', 'test_helper' ))

class IssuesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_a_newsletter
    login_as :admin
  end
  
  test 'admin submits an EMPTY issue: should see validation warnings' do

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}"

    assert_template 'admin/newsletters/show'
    click_link 'Create a new issue'

    assert_template 'admin/issues/new'
    fill_in :issue_title, :with => nil
    fill_in :issue_body, :with => nil
    click_button 'Save'

    assert_template 'admin/issues/new'
    assert_select '.field_with_error'
  end
  
  test 'admin submits a DRAFT issue: should be success and show new issue' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/new"

    assert_template 'admin/issues/new'
    fill_in :issue_title, :with => 'draft issue title'
    fill_in :issue_body, :with => 'draft issue body'
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_select '#issue' do
      assert_select 'h2', 'draft issue title'
      assert_select 'p', 'draft issue body'
    end
  end
end
