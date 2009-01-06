Factory.define_scenario :site_with_newsletter do
  factory_scenario :empty_site
  @newsletter ||= Factory :newsletter, :site => @site
end

Factory.define_scenario :site_with_newsletter_and_issue do
  factory_scenario :empty_site
  @newsletter ||= Factory :newsletter, :site => @site
  @issue ||= Factory :issue, :newsletter => @newsletter
end

Factory.define_scenario :site_with_two_users_and_newsletter do
  factory_scenario :site_with_two_users
  @newsletter = Factory :newsletter, :site => @site
end

# TODO figure how to do poly with factory
# Factory.define_scenario :site_with_newsletter_and_issue_and_subscription do
  # factory_scenario :empty_site
  # @newsletter ||= Factory :newsletter, :site => @site
  # @issue ||= Factory :issue, :newsletter => @newsletter
  # @subscription ||= Factory :subscription, :newsletter => @newsletter
# end
