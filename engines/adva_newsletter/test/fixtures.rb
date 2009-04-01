user = User.find_by_first_name("a user")
admin = User.find_by_first_name("an admin")

user_newsletter = User.create! :first_name => 'user newsletter',
                               :email => 'user-newsletter@example.com',
                               :password => 'password',
                               :verified_at => Time.utc(2009, 2, 3, 15, 0, 0)

site         = Site.create! :name => "site with newsletter",
                            :title => "site with newsletter title",
                            :email => 'newsletter@example.com',
                            :host => "site-with-newsletter.com",
                            :google_analytics_tracking_code => "GA-123456"

admin.roles << Rbac::Role.build(:admin, :context => site)
site.users  << [user, user_newsletter]
site.save!

newsletter   = site.newsletters.create! :title => "newsletter title",
                                        :desc => "newsletter desc"

issue        = newsletter.issues.create! :title => "issue title",
                                         :body => "issue body",
                                         :track => true,
                                         :tracking_campaign => "Test campaign",
                                         :tracking_source => "Test source"

subscription = newsletter.subscriptions.create! :user_id => user.id
subscription1 = newsletter.subscriptions.create! :user_id => user_newsletter.id

site.newsletters.create! :title => "newsletter without subscriptions", :desc => "newsletter desc"
