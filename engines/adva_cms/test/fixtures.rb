# empty the database
ActiveRecord::Base.connection.tables.each do |table_name|
  ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}" unless table_name == 'schema_migrations'
end

# USERS

user         = User.create! :first_name => 'a user',
                            :email => 'a-user@example.com',
                            :password => 'a password',
                            :verified_at => Time.now
             
superuser    = User.create! :first_name => 'a superuser',
                            :email => 'a-superuser@example.com',
                            :password => 'a password',
                            :verified_at => Time.now
             
admin        = User.create! :first_name => 'an admin',
                            :email => 'an-admin@example.com',
                            :password => 'a password',
                            :verified_at => Time.now
             
moderator    = User.create! :first_name => 'a moderator',
                            :email => 'a-moderator@example.com',
                            :password => 'a password',
                            :verified_at => Time.now
             
               User.create! :first_name => 'an unverified user',
                            :email => 'a-unverified-user@example.com',
                            :password => 'a password'
             
# SITES      
             
site         = Site.create! :name => 'site with sections',
                            :title => 'site with sections title',
                            :host => 'site-with-sections.com'
             
               Site.create! :name => 'another site',
                            :title => 'another site title',
                            :host => 'another-site.com'

# SECTIONS

section =   Section.create! :site => site,
                            :title => 'a section',
                            :permalink => 'a-section',
                            :comment_age => 0

            Section.create! :site => site,
                            :title => 'another section',
                            :permalink => 'another-section',
                            :comment_age => 0

category = Category.create! :section => section,
                            :title => 'a category'

# ARTICLES

article   = Article.create! :site => site,
                            :section => section,
                            :title => 'a section article',
                            :body => 'a section article body',
                            :categories => [category],
                            :tag_list => 'foo bar',
                            :author => user,
                            :published_at => Time.parse('2008-01-01 12:00:00')

            Article.create! :site => site,
                            :section => section,
                            :title => 'an unpublished section article',
                            :body => 'an unpublished section article body',
                            :categories => [category],
                            :tag_list => 'foo bar',
                            :author => user

attributes = { :site => site, :section => section, :commentable => article, :author => user }
Comment.create! attributes.merge(:body => 'the approved comment body', :approved => 1)
Comment.create! attributes.merge(:body => 'the unapproved comment body',:approved => 0)

# ROLES and MEMBERSHIPS

superuser.roles << Rbac::Role.build(:superuser)
admin.roles << Rbac::Role.build(:admin, :context => site)
moderator.roles << Rbac::Role.build(:admin, :context => section)

site.users << user
site.users << superuser
site.users << admin
site.users << moderator

# OTHERS

CachedPage.create! :site_id => site.id,
                   :section_id => section.id,
                   :url => "http://#{site.host}"

# plugin = Rails.plugins[:test_plugin].clone
# plugin.owner = site
# plugin.options = { :string => 'string', :text => 'text'}
# plugin.save!