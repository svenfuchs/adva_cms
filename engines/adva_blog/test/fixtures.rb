user = User.find_by_first_name('a user')
admin = User.find_by_first_name('an admin')
moderator = User.find_by_first_name('a moderator')

site         = Site.create! :name => 'site with blog',
                            :title => 'site with blog title',
                            :host => 'site-with-blog.com'

blog         = Blog.create! :site => site,
                            :title => 'a blog',
                            :permalink => 'a-blog',
                            :comment_age => 0,
                            :published_at => Time.parse('2008-01-01 12:00:00')

category = Category.create! :section => blog,
                            :title => 'a category'

           Category.create! :section => blog,
                            :title => 'another category'
                            
           Category.create! :section => blog,
                            :title => 'öäü'

           Category.create! :section => blog,
                            :title => '$%&'

article   = Article.create! :site => site,
                            :section => blog,
                            :title => 'a blog article',
                            :body => 'a blog article body',
                            :categories => [category],
                            :tag_list => 'foo bar',
                            :author => user,
                            :published_at => Time.parse('2008-01-01 12:00:00')

           Article.create!  :site => site,
                            :section => blog,
                            :title => 'an unpublished blog article',
                            :body => 'an unpublished blog article body',
                            :categories => [category],
                            :tag_list => 'foo bar',
                            :author => user

attributes = { :site => site, :section => blog, :commentable => article, :author => user }
Comment.create! attributes.merge(:body => 'the approved comment body', :approved => 1)
Comment.create! attributes.merge(:body => 'the unapproved comment body', :approved => 0)

admin.roles.create!(:name => 'admin', :context => site)
moderator.roles.create!(:name => 'moderator', :context => blog)

