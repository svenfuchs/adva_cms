ActionController::Routing::Routes.draw do |map|
  map.blog               'blogs/:section_id/:year/:month',
                         :controller   => 'blog_articles',
                         :action       => 'index',
                         :year => nil, :month => nil,
                         :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ },
                         :conditions   => { :method => :get }

  map.blog_category      'blogs/:section_id/categories/:category_id/:year/:month',
                         :controller   => 'blog_articles',
                         :action       => 'index',
                         :year => nil, :month => nil,
                         :requirements => { :year => /\d{4}/, :month => /\d{1,2}/},
                         :conditions   => { :method => :get }

  map.blog_tag           'blogs/:section_id/tags/:tags/:year/:month',
                         :controller   => 'blog_articles',
                         :action       => 'index',
                         :year => nil, :month => nil,
                         :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ },
                         :conditions   => { :method => :get }

  map.blog_feed          'blogs/:section_id.:format',
                         :controller   => 'blog_articles',
                         :action       => 'index',
                         :conditions   => { :method => :get }

  map.category_feed      'blogs/:section_id/categories/:category_id.:format',
                         :controller   => 'blog_articles',
                         :action       => 'index',
                         :conditions   => { :method => :get }

  map.tag_feed           'blogs/:section_id/tags/:tags.:format',
                         :controller   => 'blog_articles',
                         :action       => 'index',
                         :conditions   => { :method => :get }

  map.blog_comments      'blogs/:section_id/comments.:format',
                         :controller   => 'blog_articles',
                         :action       => 'comments',
                         :conditions   => { :method => :get }

  map.blog_article       'blogs/:section_id/:year/:month/:day/:permalink',
                         :controller   => 'blog_articles',
                         :action       => 'show',
                         :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ },
                         :conditions   => { :method => :get }

  map.blog_article_comments 'blogs/:section_id/:year/:month/:day/:permalink.:format',
                         :controller   => 'blog_articles',
                         :action       => 'comments',
                         :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ },
                         :conditions   => { :method => :get }

end