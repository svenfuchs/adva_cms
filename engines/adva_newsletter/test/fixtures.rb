user = User.find_by_first_name("a user")
admin = User.find_by_first_name("an admin")

site         = Site.create! :name => "site with newsletter",
                            :title => "site with newsletter title",
                            :host => "site-with-newsletter.com"
admin.roles << Rbac::Role.build(:admin, :context => site)

newsletter   = site.newsletters.create! :title => "newsletter title",
                                        :desc => "newsletter desc"

issue        = newsletter.issues.create! :title => "issue title",
                                         :body => "issue body"

subscription = newsletter.subscriptions.create! :user_id => user.id
