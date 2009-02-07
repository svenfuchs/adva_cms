user = User.find_by_first_name('user')
admin = User.find_by_first_name('admin')
moderator = User.find_by_first_name('moderator')

site         = Site.create! :name => 'site with blog',
                            :title => 'site with blog title',
                            :host => 'site-with-blog.com'
                     
blog         = Blog.create! :site => site,
                            :title => 'a blog',
                            :permalink => 'a-blog',
                            :comment_age => 0

category = Category.create! :section => blog,
                            :title => 'a category'
         
           Category.create! :section => blog,
                            :title => 'another category'
         
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

admin.roles << Rbac::Role.build(:admin, :context => site)
moderator.roles << Rbac::Role.build(:moderator, :context => blog)

