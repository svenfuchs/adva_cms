Wikipage.delete_all
Category.delete_all

factories :user, :sections

factory :comment,
        :body    => 'the comment body',
        :site_id    => lambda{ (Site.find(:first) || create_site).id },
        :section_id => lambda{ (Wiki.find(:first) || create_wiki).id },
        :author_id  => lambda{ (User.find(:first) || create_user).id },
        :author     => lambda{ (User.find(:first) || create_user) }, # wtf ...
        :commentable_type => 'wikipage',
        :commentable_id => lambda{ (wikipage.find(:first) || create_wikipage).id }

factory :category,
        :title   => 'a category',
        :section => lambda{ Wiki.find(:first) || create_wiki }

factory :tag,
        :name => 'foo'

factory :wikipage,
        :title   => 'the wikipage title',
        :body    => 'the wikipage body',
        :site    => lambda{ Site.find(:first) || create_site },
        :section => lambda{ Wiki.find(:first) || create_wiki },
        :author  => lambda{ User.find(:first) || create_user },
        :categories => lambda{ [Category.find_by_title('a category') || create_category] },
        :tag_list => 'foo bar',
        :updated_at => '2008-01-01 12:00:00 UTC'