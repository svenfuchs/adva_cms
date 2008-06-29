factories :user, :sections

factory :category,
        :title   => 'a category',
        :section => lambda{ Blog.find(:first) || create_blog }

factory :article,
        :title   => 'the article title',
        :body    => 'the article body',
        :excerpt => 'the article excerpt',
        :site    => lambda{ Site.find(:first) || create_site },
        :section => lambda{ Blog.find(:first) || create_blog },
        :author  => lambda{ User.find(:first) || create_user },
        :categories => lambda{ [Category.find(:first) || create_category] },
        :tag_list => 'foo bar'

factory :published_article, 
        valid_article_attributes.update(:published_at => '2008-01-01 12:00:00'),
        :class => :article        
