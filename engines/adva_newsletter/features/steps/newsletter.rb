Given /there are no newsletters/ do
  Issue.destroy_all
  Newsletter.destroy_all
end

Given /[I have | have] opened some "newsletter"/ do
  #TODO find some better way
  @newsletter = Newsletter.find(:last)
  if @newsletter.nil?
    visit 'admin/sites/1/newsletters/new'
    When 'I sumbit new "newsletter"'
    Then 'I should see new "newsletter"'
    @newsletter = Newsletter.find(:last)
  end
  visit "admin/sites/1/newsletters/#{@newsletter.id}"
end
