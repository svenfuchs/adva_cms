require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class NoIssuesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter
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
  
  test 'admin submits a DRAFT issue: should be success and show new issue as draft' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/new"

    assert_template 'admin/issues/new'
    fill_in :issue_title, :with => 'draft issue title'
    fill_in :issue_body, :with => 'draft issue body'
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_select '#issue' do
      assert_select 'h2', /draft issue title/
      assert_select 'p', 'draft issue body'
      assert_select "span.draft", "Draft"
    end
  end
  
  test 'admin submits a NON-DRAFT issue: should be success and show new issue' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/new"

    assert_template 'admin/issues/new'
    fill_in :issue_title, :with => 'issue title'
    fill_in :issue_body, :with => 'issue body'
    uncheck "issue-draft"
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_select '#issue' do
      assert_select 'h2', 'issue title'
      assert_select 'p', 'issue body'
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
    assert_flash 'Newsletter issue was successfully updated'
    assert_select '#issue' do
      assert_select 'h2', /EDITED issue title/
      assert_select 'p', 'EDITED issue body'
    end
  end
  
  test 'admin DELETES issue: should go to trash' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/"

    assert_template 'admin/issues/index'
    assert_equal 1, @newsletter.issues.count
    click_link 'delete'

    assert_template 'admin/issues/index'
    assert_flash 'Newsletter issue was successfully moved to trash.'
    assert_equal 0, @newsletter.issues.count
  end

  def teardown
    remove_all_test_cronjobs
  end
end  

class IssuesWithSubscriptionTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin
    @other_user = Factory :other_user

    # TODO: perhaps factory has some better way for poly
    @subscription = Subscription.new(:user_id => @other_user.id)
    @subscription.subscribable_id = 1
    @subscription.subscribable_type = 'Newsletter'
    @subscription.save
    @issue.draft = 0
    @issue.save

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"
    assert_template 'admin/issues/show'
  end

  test 'admin SENDS NOW: should be added to delivery queue (currently delivery is mocked)' do
    click_button 'Send now'

    assert_template 'admin/issues/show'
    assert_flash 'Newsletter issue was successfully added to the delivery queue'
  end
  
  test 'admin SENDS WITH DELAY: should be added to delivery queque with delay (deliver mocked)' do
    click_button 'Send later'

    assert_template 'admin/issues/show'
    assert_flash 'Newsletter issue was successfully added to the queue to send out later'
  end

  test 'admin submits SENDS ONLY TO MYSELF: should send issue only to myself (deliver mocked)' do
    check 'send_test'
    click_button 'Send now'

    assert_template 'admin/issues/show'
    assert_flash 'Newsletter issue was successfully sent out only to you.'
  end
  
  def teardown
    remove_all_test_cronjobs
  end
end
