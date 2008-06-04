## Stubby - lightweight and fast stubbing

Stubby is a lightweight and fast stubbing framework that was 

* designed to help with the repetitive work of setting up stub scenarios for specifying/testing and
* optimized for speed and ease of use.
 
Stubby does not track references to stubbed methods on real objects (like
RSpec's `stub!` method does it which is used by `stub_model` & co).

Instead it dynamically creates a Ruby class for every stub object once. These
classes will then be instantiated for every specification (or test). This
circumvents the overhead of adding, tracking and removing lots of methods
and can - depending on your stubs and specs - result in significant speed
improvements.

## Stubs setup

Stubby comes with a slick DSL to make it easy to describe stub setups. Basically
there are three main statements:

* `define Model &block` - defines a stub base class that camouflages as a model class
* `instance :key, methods` - defines a concrete stub that inherits from a stub base class and will be instantiated on request
* `scenario :key &block` - defines a code block that can be executed from your spec (e.g. in before :each blocks)

Things are pretty much readable and self-explaining:

    define Site do
      methods :save => true, :destroy => true, :active? => true
      instance :homepage, :id => 1
      instance :customer, :id => 2, :active? => false
    end

This creates a stub base class that camouflages as your `Site` model (i.e. it
behaves as this model when methods like `class`, `is_a?`, `===` etc. are sent to it).

For the Site stub base class there are a couple of methods defined (stubbed)
that you can call in your specs and that will return the given values (like
`save` will return `true`).

It also defines two stub instances for this class that can be accessed through
the keys `:homepage` and `:customer`. These both respond to the `id` method. The 
`:customer` instance additionally overwrites the `active?` value that's present
in the base class.

## Access stubs

You can access these stubs from 

* the stub base class definition block (like the one above)
* scenario blocks (see below)
* your specs

To access them you can use the following method apis. With the Site stub base
class above being defined:

    stub_site             # returns the first defined stub instance (i.e. :homepage)
    stub_site(:homepage)  # returns the :homepage stub instance
    stub_sites            # returns an array with all defined stub instances
    stub_sites(:homepage) # returns an array containing the :homepage stub instance

You can also use the `lookup(:site, :homepage)` method in the same way in case
you need it.

Also, note that you can use these accessors from within the stub base class
definition, too:

    define Site do
      instance :homepage, :next => stub_site(:customer)
      instance :customer, :next => stub_site(:homepage)
    end

This creates a method `next` on both instances which return the respective 
stub instances.

For convenience you can pass arrays of method names as keys of method
hashs:

    define Site do
      methods [:save, :destroy, :active?] => true # same result as above
    end

## Stubbing ActiveRecord associations

To make stubbing of more complex ActiveRecord models easier there are also the
following helpers:

    define Site do
      has_many :sections, [:find, :build] => stub_section,
                           :paginate => stub_sections  
    end

This has the expected effects. With this definition in place the following 
lines will now all return the same section stub object:

    stub_site.sections.first
    stub_site.sections.find
    stub_site.sections.build
    stub_site.sections.paginate.first

Watch the first of these lines! As you can see the sections `has_many_proxy`
will automatically be populated with the array stub_sections if you don't
specify anything explicitely. I.e. that's the same as:

    define Site do
      has_many :sections, stub_sections,
                          [:find, :build] => stub_section,
                           :paginate => stub_sections  
    end


If you want the sections array to contain something else you can specify
it:

    define Site do
      has_many :sections, stub_sections(:root),
                          [:find, :build] => stub_section,
                           :paginate => stub_sections  
    end

Finally there are also the `has_one` and `belongs_to` statements which behave 
in the expected manner:

    define Site do
      has_one :api_key
      belongs_to :user
    end

The `belongs_to` statement implicitely defines the `user_id` method so that it
returns the id defined for the `stub_user` stub.

## Scenarios

A scenario is simply a code block that can be accessed and executed from your
specs. You can define a scenario like this:

    scenario :default do
      @site = stub_site
      Site.stub!(:find).and_return @site 
    end

You can then invoke this scenario from your Spec like so:

    before :each do
      scenario :default # pass as many scenario names as you like
    end

Because the scenario code block is evaluated in the scope of the before :each
block the @site instance variable is then accessible from within your specs.

## Installation and Setup

Install Stubby as a usual Rails plugin and add the following line somewhere 
in your specs where it gets executed. The best place for this is probably
your `spec/spec_helper.rb` file:

    Stubby::Loader.load

This requires the stubby code and loads the stub definition files once.

## Stub definition files

Stubby assumes that you have on directory where you store your stub definition
files (and nothing else). A stub definition file is just a ruby file that contains
all or some of your stub base class and scenario definitions like described above. 
You can structure your files as you like.

By default Stubby assumes that you 

* use a directory named `stubs/`
* that is located beneath the directory of your `spec_helper.rb` file
* that starts requires the stubby code

Stubby then tries to guess the correct directory location. If it gets things 
wrong or if you want to use a different setup you can specify the directory
where it looks for your stub definitions files like this:

    Stubby.directory = 'path/to/stubs'

## Limitations

Be aware that Stubby is a framework for plain stubs. That means that it doesn't
make a single attemp of looking at your model classes and trying to mimick 
their behaviour. This is different from what other solutions do (which might
instantiate full functional model objects, like fixtures, or at least mimick
the model's attributes or similar).

Thus you need to define every single method that your specs call. Personally
I feel that this is an advantage because it makes visible *what* portions
of the code my specs actually run (and what they shouldn't). But your mileage
may vary.

Also, with Stubby it is currently not possible:

* define class methods in stub base classes. You still need to stub class methods manually. The scenario block is a good place to stub common methods though.
* stub methods in a way so that they return different results depending on a certain parameter passed. You can still use RSpec `stub!(:method).with(:param).and_return(result)` for that though.

If you want to help me with these, please let me know :)

Also, this code is brand new. Consider this an alpha release. I have written
this library to clean-up and speed-up the 1000+ specs of a project that I'm 
currently working on. For me Stubby works quite well in this project's specs 
and it runs these specs in less than 30 seconds (which is less then 50% of
what a solution with `mock_model` needed).

That doesn't mean that there aren't any major bugs or problems though. Please
send me your pull requests, patches or just bug requests if so.

## Similar solutions

There are a couple of similar solutions that aim at the same problem but all
go down different routes. I highly recommend to have a look at:

* [Fixture Scenarios](http://code.google.com/p/fixture-scenarios/) by Tom Preston-Werner, extends Rails' native fixtures
* [Model Stubbing](http://ar-code.svn.engineyard.com/plugins/model_stubbing/README) by Rick Olson, creates in-memory versions of your models
* [Exemplar](http://www.bofh.org.uk/articles/2007/08/05/doing-the-fixture-thing) by Piers Cawley

## The name

I was told that in Canada a "stubby" is a certain kind of beer bottle. The
[Wikipedia page](http://en.wikipedia.org/wiki/Beer_bottle) lists a couple of
advantages that perfectly match the reasons why I've written this library in
the first place:

* easier to handle
* chills faster
* less breakage
* lighter in weight
* less storage space
* lower center of gravity

Now, given that I've thought of this name before I knew this page I think 
that's pretty funny and a perfect name for the library.

Also, I'm not a native English speaker but I've been informed on #rubyonrails
that "Stubby" might also have some sexual connotations in some parts of the
English speaking world.

## Etc

Authors: [Sven Fuchs](http://www.artweb-design.de) <svenfuchs at artweb-design dot de>  
License: MIT 