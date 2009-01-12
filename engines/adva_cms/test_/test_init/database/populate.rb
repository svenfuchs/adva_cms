# ActiveRecord::Migration.suppress_messages do
#   load "#{RAILS_ROOT}/db/schema.rb"
# end

# empty all tables, once
ActiveRecord::Base.connection.tables.each do |table_name|
  ActiveRecord::Base.connection.execute "DELETE FROM #{table_name}" unless table_name == 'schema_migrations'
end

# setup some data, once

site_with_sections =
Site.create!     :name => 'site with sections',
                 :title => 'site with sections title',
                 :host => 'site-with-sections.com'

section =
Section.create!  :site => site_with_sections,
                 :title => 'a section',
                 :permalink => 'a-section',
                 :comment_age => 0

another_section =
Section.create!  :site => site_with_sections,
                 :title => 'another section',
                 :permalink => 'another-section',
                 :comment_age => 0

section_category =
Category.create! :section => section,
                 :title => 'a category'


site_with_blog =
Site.create!     :name => 'site with blog',
                 :title => 'site with blog title',
                 :host => 'site-with-blog.com'

blog =
Blog.create!     :site => site_with_blog,
                 :title => 'a blog',
                 :permalink => 'a-blog',
                 :comment_age => 0

blog_category =
Category.create! :section => blog,
                 :title => 'a category'


site_with_wiki =
Site.create!     :name => 'site with wiki',
                 :title => 'site with wiki title',
                 :host => 'site-with-wiki.com'

wiki =
Wiki.create!     :site => site_with_wiki,
                 :title => 'a wiki',
                 :permalink => 'a-wiki',
                 :comment_age => 0

wiki_category =
Category.create! :section => wiki,
                 :title => 'a category'


user =
User.create!     :first_name => 'a user',
                 :email => 'a-user@example.com',
                 :password => 'a password'

superuser =
User.create!     :first_name => 'a superuser',
                 :email => 'a-superuser@example.com',
                 :password => 'a password'
superuser.grant :superuser

admin =
User.create!     :first_name => 'an admin',
                 :email => 'an-admin@example.com',
                 :password => 'a password'
admin.grant :admin, site_with_sections
admin.grant :admin, site_with_blog

moderator =
User.create!     :first_name => 'a moderator',
                 :email => 'a-moderator@example.com',
                 :password => 'a password'
moderator.grant :moderator, section
moderator.grant :moderator, blog



section_article =
Article.create!  :site => site_with_sections,
                 :section => section,
                 :title => 'a section article',
                 :body => 'a section article body',
                 :categories => [section_category],
                 :tag_list => 'foo bar',
                 :author => user,
                 :published_at => Time.parse('2008-01-01 12:00:00')

blog_article =
Article.create!  :site => site_with_blog,
                 :section => blog,
                 :title => 'a blog article',
                 :body => 'a blog article body',
                 :categories => [blog_category],
                 :tag_list => 'foo bar',
                 :author => user,
                 :published_at => Time.parse('2008-01-01 12:00:00')

home_wikipage =
Wikipage.create! :site => site_with_wiki,
                 :section => wiki,
                 :title => 'home',
                 :body => 'home wikipage body',
                 :categories => [wiki_category],
                 :tag_list => 'foo bar',
                 :author => user

another_wikipage =
Wikipage.create! :site => site_with_wiki,
                 :section => wiki,
                 :title => 'another wikipage title',
                 :body => 'another wikipage body',
                 :tag_list => 'foo bar',
                 :author => user


comment_attrs = { :body => 'the comment body',
                 :site => section_article.site,
                 :section => section_article.section,
                 :commentable => section_article,
                 :author => user }

approved_section_article_comment   = Comment.create! comment_attrs.merge(:approved => 1)
unapproved_section_article_comment = Comment.create! comment_attrs.merge(:approved => 0)

comment_attrs = { :body => 'the comment body',
                 :site => blog_article.site,
                 :section => blog_article.section,
                 :commentable => blog_article,
                 :author => user }

approved_blog_article_comment   = Comment.create! comment_attrs.merge(:approved => 1)
unapproved_blog_article_comment = Comment.create! comment_attrs.merge(:approved => 0)

cached_page =
CachedPage.create! :site_id => site_with_sections.id,
                   :section_id => section.id

plugin = Engines.plugins[:test_plugin].clone
plugin.owner = site_with_sections
plugin.options = { :string => 'string', :text => 'text'}
plugin.save!