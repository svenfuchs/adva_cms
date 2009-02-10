TODO

test url_helper rewriting, see blog_routes_spec
started using With style in unit/model test ... revert that.

DOC

test run stages
- populate database once
- run every test within a transaction
- reference (and maybe modify) existing records during test setup/before stage


Start the test server with init script:
vendor/adva/spec/test_server/bin/server -l vendor/adva/engines/adva_cms/test/test_helper/test_server/init.rb
vendor/adva/spec/test_server/bin/test vendor/adva/engines/adva_cms/test/functional/admin/install_controller_test.rb -l 34


--------------

When using With keep in mind that different from RSpec and Context this construct does *not* define a full test but an assertion with a test:

it "is not a test but an assertion" do
	# ...
end

That means that when you have multiple `it` blocks in a context (test) then you need to pay attention to the state of your test data. E.g. you can:

- use @record.reload to reset a record to its original state
- use expectation do ... end to reset and verify RR expectations

--------------

A common pattern that I encounter with my specs is that I want to test the same things in different contexts. This sounds trivial, but curiously with all current test libraries that I know it's quite a hassle.

Imagine you have a controller that exposes functionality in different contexts. E.g. Mephisto has an Admin::ArticlesController that can be used for managing articles for both Sections and Blogs while Blogs derive from Sections. (Well, it's not exactly like this, but you get the point.)

Now we might want to test that the :new action renders the :new template when the current section is a Section or when it is a Blog.

...

describe "some common behaviour", :shared => true do
  # actual assertions
end

describe "foo" do
	behaves_link :some_common_behaviour
end

describe "bar" do
	behaves_link :some_common_behaviour
end

with [:foo, :bar] do
	# actual assertions
end
