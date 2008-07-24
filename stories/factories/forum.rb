factories :user, :sections

factory :post,
        :body       => 'the post body',
        :site_id    => lambda{ (Site.find(:first) || create_site).id },
        :section_id => lambda{ (Forum.find(:first) || create_forum).id },
        :author_id  => lambda{ (User.find(:first) || create_user).id },
        :author     => lambda{ (User.find(:first) || create_user) }, # wtf ...
        :commentable_type => 'Topic',
        :commentable_id => lambda{ (Topic.find(:first) || create_topic).id }

factory :board,
        :title   => 'a board',
        :section => lambda{ Forum.find(:first) || create_forum }

factory :topic,
        :title   => 'the topic title',
        :site    => lambda{ Site.find(:first) || create_site },
        :section => lambda{ (Forum.find(:first) || create_forum).id },
        :author  => lambda{ User.find(:first) || create_user }
        
