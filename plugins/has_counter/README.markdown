## Has Counter

Allows to cache the number of records for a `has_many` association.

Yes, this is the same thing you can do by setting the `:counter_cache` option
on the corresponding `belongs_to` association.

The reason for reinventing the `counter_cache` wheel here is that
`counter_cache` is a bit inflexible. We need to "hardcode" the counter_cache
column and thereby clutter the schema. This can especially get annoying in
combo with STI, when - e.g. one subclass needs some `counter_caches` that are
specific to this subclass only.

Instead, with `has_counter`, counters can be separated into an external table 
with generic column names. 

The ActiveRecord `counter_cache` mechanism also requires to put the
`:counter_cache` directive on the `belongs_to` association of the counted class,
which adds some tight coupleing that we might want to avoid.

Instead, with `has_counter`, we can observe the counted class and update our
counters "from the outside", so the counted class does not need to know about
the fact that somebody else keeps a counter on it.

## Usage

    class User
      has_counter :posts
    end
    
This will add a `has_one :post_counter` association to the User model as well
as the appropriate callbacks for creating the initial counter object when a
User is created and in/decrementing the counter when a Post is created or
destroyed. 

For convenience it also adds a `posts_count` method to the User model that you
should use to read the actual numeric count value. 

In case you need that you can use the following methods to manually
in/decrement or set the counter value:

    user.posts_counter.increment! # increments and saves the counter
    user.posts_counter.decrement! # decrement and saves the counter
    user.posts_counter.set(5)     # sets the counter to 5 and saves it
    
## Limitations

There are quite some. The above example expects that there is the following
association on the Posts model:  

    class Post
      belongs_to :user
    end  
    
`User.has_counter :posts` also expects that a Post model exists and that this
is the one you want to count. At this point you can **not** count arbitrary
associations like:

    class Post
      has_counter :approved_comments # with special conditions/callbacks
    end


    