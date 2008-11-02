Wikipage.delete_all
Category.delete_all

factories :user, :sections

factory :wikipage,
        :title   => 'the wikipage title',
        :body    => 'the wikipage body',
        :site    => lambda{ Site.find(:first) || create_site },
        :section => lambda{ Wiki.find(:first) || create_wiki },
        :author  => lambda{ User.find(:first) || create_user },
        :categories => lambda{ [Category.find_by_title('a category') || create_category] },
        :tag_list => 'foo bar'
