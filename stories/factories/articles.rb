Article.delete_all
Category.delete_all

factories :user, :sections

factory :comment,
        :body    => 'the comment body',
        :site_id    => lambda{ (Site.find(:first) || create_site).id },
        :section_id => lambda{ (Blog.find(:first) || create_blog).id },
        :author_id  => lambda{ (User.find(:first) || create_user).id },
        :commentable_type => 'Article',
        :commentable_id => lambda{ (Article.find(:first) || create_published_article).id }

factory :category,
        :title   => 'a category',
        :section => lambda{ Blog.find(:first) || create_blog }

factory :tag,
        :name => 'foo'

factory :article,
        :title   => 'the article title',
        :body    => 'the article body',
        :excerpt => 'the article excerpt',
        :site    => lambda{ Site.find(:first) || create_site },
        :section => lambda{ Blog.find(:first) || create_blog },
        :author  => lambda{ User.find(:first) || create_user },
        :categories => lambda{ [Category.find_by_title('a category') || create_category] },
        :tag_list => 'foo bar',
        :published_at => '2008-01-01 12:00:00'

factory :published_article, 
        valid_article_attributes.update(:published_at => '2008-01-01 12:00:00'),
        :class => :article