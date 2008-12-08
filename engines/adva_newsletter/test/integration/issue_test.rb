require File.expand_path(File.join(File.dirname(__FILE__), '../../../adva_cms/test', 'test_helper' ))

class NoIssuesTest < ActionController::IntegrationTest
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

class IssuesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin
  end
  
  test 'admin EDITS issue: should be success' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"

    assert_template 'admin/issues/show'
    click_link 'Edit'

    assert_template 'admin/issues/edit'
    fill_in :issue_title, :with => 'EDITED issue title'
    fill_in :issue_body, :with => 'EDITED issue body'
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_select 'p.flash-notice', 'Edited successfully.'
    assert_select '#issue' do
      assert_select 'h2', 'EDITED issue title'
      assert_select 'p', 'EDITED issue body'
    end
  end
end  

class IssuesWithSubscriptionsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue_and_two_subscriptions
    login_as :admin
  end

  test 'admin DELIVERS issue NOW: should be added to delivery queue (currently delivery is mocked)' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}/edit"

    assert_template 'admin/issues/edit'
    click_button 'Deliver now'

    assert_template 'admin/issues/show'
    assert_select 'p.flash-notice', 'Issue with 2 subscribers has been added successfully to the delivery queue.'
  end
  
  test 'admin DELIVERS TEST issue NOW: should be only one issue added to delivery queue, issue recipent should be logged in user (deliver mocked)' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}/edit"

    assert_template 'admin/issues/edit'
    check 'only to me'
    click_button 'Deliver now'

    assert_template 'admin/issues/show'
    assert_select 'p.flash-notice', 'Test issue for yourself has been added successfully to the delivery queue.'
  end
end
