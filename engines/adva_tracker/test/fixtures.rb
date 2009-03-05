user  = User.find_by_first_name("a user")
admin = User.find_by_first_name("an admin")

site = Site.create! :name  => "site with tracker",
                    :title => "site with tracker title",
                    :host  => "site-with-tracker.com"

admin.roles << Rbac::Role.build(:admin, :context => site)

tracker = Tracker.create! :site        => site,
                          :title       => "tracker",
                          :permalink   => "tracker",
                          :comment_age => 0

project = tracker.projects.create! :title => "project title",
                                   :desc  => "project desc"

ticket = project.tickets.create! :title  => "ticket title",
                                 :body   => "ticket body",
                                 :author => user
