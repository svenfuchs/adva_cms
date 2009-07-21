user  = User.find_by_first_name('a user')
admin = User.find_by_first_name('an admin')

site =
Site.create!     :name => 'site with wiki',
                 :title => 'site with wiki title',
                 :host => 'site-with-wiki.com'
admin.roles.create!(:name => 'admin', :context => site)

wiki =
Wiki.create!     :site        => site,
                 :title       => 'a wiki',
                 :permalink   => 'a-wiki',
                 :comment_age => 0,
                :published_at => Time.parse('2008-01-01 12:00:00')

category =
Category.create! :section => wiki,
                 :title => 'a category'

home_wikipage =
Wikipage.create! :site => site,
                 :section => wiki,
                 :title => 'home',
                 :body => 'home wikipage body (initial version)',
                 :categories => [category],
                 :tag_list => 'foo bar',
                 :author => user
home_wikipage.update_attributes!(:body => 'home wikipage body (revised version)')

another_wikipage =
Wikipage.create! :site => site,
                 :section => wiki,
                 :title => 'another wikipage title',
                 :permalink => 'another-wikipage',
                 :body => 'another wikipage body (initial version)',
                 :tag_list => 'foo bar',
                 :author => user
another_wikipage.update_attributes!(:body => 'another wikipage body (first revised version)')
another_wikipage.update_attributes!(:body => 'another wikipage body (second revised version)')
another_wikipage.update_attributes!(:body => 'another wikipage body (third revised version)')

