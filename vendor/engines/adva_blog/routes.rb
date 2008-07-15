# We use the :id parameter here for the section id even when it's followed
# by a :category_id to keep this consistent with other section routes (e.g.
# section and wiki).

with_options :controller => 'blog', :action => 'index', :requirements => { :method => :get } do |blog|
                                
  blog.blog                    "blogs/:section_id/:year/:month",
                                :year => nil, :month => nil,
                                :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/ }
                                
  blog.blog_category           "blogs/:section_id/categories/:category_id/:year/:month",
                                :year => nil, :month => nil,
                                :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/}
                                
  blog.blog_tag                "blogs/:section_id/tags/:tags/:year/:month",
                                :year => nil, :month => nil,
                                :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/ }
                                
  blog.formatted_blog          "blogs/:section_id.:format"
  blog.formatted_blog_category "blogs/:section_id/categories/:category_id.:format"
  blog.formatted_blog_tag      "blogs/:section_id/tags/:tags.:format"               
end                             

                                
map.article                    "blogs/:section_id/:year/:month/:day/:permalink",
                                :controller   => 'blog',
                                :action       => "show",
                                :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

map.formatted_blog_comments    'blogs/:section_id/comments.:format',
                                :controller   => 'blog',
                                :action       => "comments",
                                :requirements => { :method => :get }

map.formatted_blog_article_comments "blogs/:section_id/:year/:month/:day/:permalink.:format",
                                :controller   => 'blog',
                                :action       => "comments",
                                :requirements => { :method => :get, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }