map.blog                    "blogs/:section_id/:year/:month",
                            :controller   => 'blog',
                            :action       => "index",
                            :year => nil, :month => nil,
                            :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/ }
                            
map.blog_category           "blogs/:section_id/categories/:category_id/:year/:month",
                            :controller   => 'blog',
                            :action       => "index",
                            :year => nil, :month => nil,
                            :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/}
                            
map.blog_tag                "blogs/:section_id/tags/:tags/:year/:month",
                            :controller   => 'blog',
                            :action       => "index",
                            :year => nil, :month => nil,
                            :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/ }
                            
map.formatted_blog          "blogs/:section_id.:format",
                            :controller   => 'blog',
                            :action       => "index",
                            :requirements => { :method => :get }
                            
map.formatted_blog_category "blogs/:section_id/categories/:category_id.:format",
                            :controller   => 'blog',
                            :action       => "index",
                            :requirements => { :method => :get }
                            
map.formatted_blog_tag      "blogs/:section_id/tags/:tags.:format",
                            :controller   => 'blog',
                            :action       => "index",
                            :requirements => { :method => :get }
                            
                            
map.article                 "blogs/:section_id/:year/:month/:day/:permalink",
                            :controller   => 'blog',
                            :action       => "show",
                            :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }
                            
map.formatted_blog_comments 'blogs/:section_id/comments.:format',
                            :controller   => 'blog',
                            :action       => "comments",
                            :requirements => { :method => :get }

map.formatted_blog_article_comments "blogs/:section_id/:year/:month/:day/:permalink.:format",
                            :controller   => 'blog',
                            :action       => "comments",
                            :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ },
                            :conditions   => { :method => :get }

