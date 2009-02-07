Time.stubs(:now).returns Time.utc(2009,2,3, 15,00,00)
Date.stubs(:today).returns Date.civil(2009,2,3)

user = User.find_by_first_name("a user")
admin = User.find_by_first_name("an admin")

user_newsletter = User.create! :first_name => 'user newsletter',
                               :email => 'user-newsletter@example.com',
                               :password => 'password',
                               :verified_at => Time.now

site         = Site.create! :name => "site with newsletter",
                            :title => "site with newsletter title",
                            :email => 'newsletter@example.com',
                            :host => "site-with-newsletter.com"
admin.roles << Rbac::Role.build(:admin, :context => site)
site.users  << [user, user_newsletter]
site.save!

newsletter   = site.newsletters.create! :title => "newsletter title",
                                        :desc => "newsletter desc"

issue        = newsletter.issues.create! :title => "issue title",
                                         :body => "issue body"

subscription = newsletter.subscriptions.create! :user_id => user.id
subscription1 = newsletter.subscriptions.create! :user_id => user_newsletter.id
  
site.newsletters.create! :title => "newsletter without subscriptions", :desc => "newsletter desc"
