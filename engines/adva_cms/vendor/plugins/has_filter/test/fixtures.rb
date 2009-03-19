HasFilterArticle.destroy_all
HasFilterCategory.destroy_all
HasFilterCategorization.destroy_all

first  = HasFilterArticle.create! :title => 'first',  :body => 'first',  :published => 1, :approved => 0, :tag_list => 'foo bar baz'
second = HasFilterArticle.create! :title => 'second', :body => 'second', :published => 1, :approved => 1, :tag_list => 'foo bar'
third  = HasFilterArticle.create! :title => 'third',  :body => 'third',  :published => 0, :approved => 0, :tag_list => 'foo'

foo = HasFilterCategory.create! :title => 'has_filter foo'
bar = HasFilterCategory.create! :title => 'has_filter bar'

first.categories  << foo << bar
second.categories << foo

