## Page Cache Tagging

Largely inspired by Rick Olson's [Referenced Page Caching](http://svn.techno-weenie.net/projects/plugins/referenced_page_caching/)
this plugin uses a more normalized database schema for better performance 
and adds a powerful and convenient tracking mechanism to allow for more 
precise cache expiration.

Basically the plugin allows you to ActiveRecord instances with read-access observers, 
which will then track read access on the objects attributes or other methods
and save a reference to the database. These references then allow you to 
expire cached pages when the tracked objects are changed.

Let's look at an example. Consider you have a blog application that displays
an article and tags on an show page. In the controller you could then set up 
referenced page caching like this:

    class BlogController < ApplicationController
      caches_page_with_references :show, :track => ['@article', {'@site' => :tags}]
    end

This will register the `@article` and `@site` instance variables for read-access
tracking when the controller action calls its render method: We're interested 
in read access that happens from our view because that's what gets cached.

Now, when the view accesses the @article with

    <%= @article.title %>

the observer will notice that and save a reference to the database that says: 
this article was referenced on the page with this URL. (The same applies to
the @site object, except that we only track access to the tags method here.)

Thus, we can put an ArticleSweeper in place that, when the article gets updated,
will remove all pages for all URLs from the cache that reference this article. 
(Or expire all pages that reference the `@site`'s tags collection when the tags
change.)

    class Admin::ArticlesController < ApplicationController
      cache_sweeper :article_sweeper, :only => [:create, :update, :destroy]
    end

The ArticleSweeper could look like this:

    class ArticleSweeper < CacheReferences::Sweeper
      observe Article
    
      def after_save(article)
        expire_cached_pages_by_reference article
      end
      alias after_destroy after_save
    end


## Limitations

You can only track instance variables which should work in most cases. Thus
you have to make sure you have an instance variable assigned to your view and
that it gets accessed from your view if you want to track it. This should be
the most common case though.

Also, you can currently only track ActiveRecord instances. It should be easy
though to abstract things a bit to also allow to track arbitrary object if 
you need it. 

## A word of warning

With this plugin you can easily build a very fine-grained cache tracking
system. E.g. you could track all references to all of your tags individually
and only expire pages when a single certain tag was referenced on a page.

Keep in mind though, that this tracking can quickly add up to a significant
overhead that results in a very large references table. On the other hand it's
usually not too expensive to just expire some more cached pages if something
unrelated changes. So you'll want to think about the best balance between
fine-grained cache tracking and performance.


## Etc

Authors: [Sven Fuchs](http://www.artweb-design.de) <svenfuchs at artweb-design dot de>  
Kudos: [Rick Olson](http://techno-weenie.net/) for the original [Referenced Page Caching](http://svn.techno-weenie.net/projects/plugins/referenced_page_caching/) plugin  
License: MIT 