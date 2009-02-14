require File.dirname(__FILE__) + '/../../test_helper'
# RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../../../../../../..") unless defined?(RAILS_ROOT)
#
# require 'rubygems'
# require 'active_support'
# require 'active_support/test_case'
# require 'action_controller'
# require File.expand_path(File.dirname(__FILE__) + '/../../../../../test/rr/lib/rr')
# require File.expand_path(File.dirname(__FILE__) + '/../../../lib/theme_support/compiled_template_expiration')
#
# class Theme
#   def self.root_dir
#     "#{RAILS_ROOT}/tmp"
#   end
# end unless defined?(Theme)

class DynamicViewPathTest < ActiveSupport::TestCase
  def setup
    super
    @now = Time.now
    RR.stub(Time).now.returns @now
    Rails.backtrace_cleaner.remove_silencers!
  end

  def teardown
    super
    FileUtils.rm_r "#{RAILS_ROOT}/tmp/themes" rescue Errno::ENOENT
    ActionView::Base::CompiledTemplates.instance_methods(false).each do |m|
      ActionView::Base::CompiledTemplates.send(:remove_method, m) if m =~ /^_run_/
    end
  end

  test "a new template instance it reads the fresh source" do
    # you never know what actionview magic does ... so let's assert this
    template = create_template
    assert_match /"the default template"/, template.compiled_source
    File.open(template.filename, 'w+') { |f| f.write('the updated template') }
    template = ActionView::Template.new(template.filename, template.load_path)
    assert_match /"the updated template"/, template.compiled_source
  end
  
  test "can lookup templates" do
    assert_nothing_raised { view_paths.find_template("layouts/default", "html") }
  end
  
  test "without expiration it does not update the compiled source from disk" do
    template = view_paths.find_template("layouts/default", "html")   # look up a cached template
    compiled_source = template.compiled_source
    update_template_file(template.filename)                          # change the file
    assert_equal template.compiled_source, compiled_source           # template compiled_source is still the same
  end
  
  test "with expiration it updates the compiled source from disk" do
    template = view_paths.find_template("layouts/default", "html")   # look up a cached template
    template.send :compile, {}
    compiled_source = template.compiled_source
    update_template_file(template.filename)                          # change the file
    template.expire_from_memory!                                     # expire the memoized stuff
    assert_not_equal template.compiled_source, compiled_source       # template compiled_source has now changed
  end
  
  test "with the template being dynamic and modified since compile it recompiles the template" do
    template = view_paths.find_template("layouts/default", "html")   # look up a cached template
    template.send :compile, {}                                       # compile the template
    compiled_source = template.compiled_source
    update_template_file(template.filename)                          # change the file
    assert template.dynamic?
    assert template.stale?
    RR.mock(template).compile!(anything, {})                         # expect it will recompile
    template.send :compile, {}
    assert_not_equal template.compiled_source, compiled_source       # make sure compiled_source has changed
  end

  
  # Does not happen as currently DynamicEagerPath is not used. Should do that
  # at some point.
  # test "load_path finds new a template after it was added" do
  #   paths = view_paths
  #   template = create_template "public/themes/theme-1/templates", "something/new.html.erb"
  #   assert_nothing_raised { paths.find_template("something/new", "html") }
  # end
  
  test "can render a template" do
    template = create_template
    view = ActionView::Base.new(template.load_path)
    assert_match /the default template/, view.render(:file => 'layouts/default.html')
  end
  
  test "adds a new template to an eager-loaded view_paths" do
    template = create_template
    view = ActionView::Base.new(template.load_path)
    template = create_template("public/themes/theme-1/templates", 'something/new.html')
    FileUtils.touch(template.load_path)
    assert_nothing_raised { view.render(:file => 'something/new.html') }
  end

  # Does not happen as currently DynamicEagerPath is not used. Should do that
  # at some point.
  # test "removes a deleted template from an eager-loaded view_paths" do
  #   template = create_template("public/themes/theme-1/templates", 'something/new.html')
  #   view = ActionView::Base.new(view_paths)
  #   assert view.view_paths.find_template('something/new.html')
  #   FileUtils.rm(template.filename)
  #   FileUtils.touch("/Users/sven/Development/projects/adva-cms/adva-cms/tmp/themes/public/themes/theme-1/templates")
  #   assert_raises(ActionView::MissingTemplate) { view.render(:file => 'something/new.html') }
  # end

  test "updates a template in an eager-loaded view_paths" do
    template = create_template
    view = ActionView::Base.new(template.load_path)
    assert_match /the default template/, view.render(:file => 'layouts/default.html')
    update_template_file(template.filename)
    assert_match /the updated template/, view.render(:file => 'layouts/default.html')
  end
  
  test "dynamic? is true if the template is a theme template (single-site mode)" do
    template = create_template("public/themes/theme-1/templates", "layouts/default.html.erb")
    assert template.dynamic?
  end
  
  test "dynamic? is true if the template is a theme template (multi-site mode)" do
    template = create_template("public/themes/site-1/theme-1/templates", "layouts/default.html.erb")
    assert template.dynamic?
  end
  
  test "dynamic? is false if the template is a regular app template" do
    template = create_template("app/views", "layouts/default.html.erb")
    assert !template.dynamic?
  end
  
  test "stale? is false if the theme dir has not been touched since the template has been compiled" do
    template = create_template
    File.utime(@now, @now, template.filename)
    template.mtime # caches the mtime
    File.utime(@now, @now - 1, template.filename)
    assert !template.stale?
  end
  
  test "stale? is true if the file has been touched since the template was compiled" do
    template = create_template
    File.utime(@now, @now, template.filename)
    template.mtime # caches the mtime
    File.utime(@now, @now + 1, template.filename)
    assert template.stale?
  end
  
  test "stale? is true if the template has not been compiled yet" do
    template = create_template
    assert template.stale?
  end
  
  test "stale? is true if theme directory does not exist" do
    template = create_template
    FileUtils.rm_r "#{RAILS_ROOT}/tmp/themes"
    assert template.stale?
  end
  
  test "expire_from_memory! expires compiled theme templates" do
    template = create_template
    template.send :compile, {}
    template.expire_from_memory!
    assert ActionView::Base::CompiledTemplates.instance_methods(false).empty?
  end

  protected

    def create_template(view_path = "public/themes/theme-1/templates", filename = "layouts/default.html.erb")
      view_path = "#{RAILS_ROOT}/tmp/themes/#{view_path}"
      FileUtils.mkdir_p(File.dirname("#{view_path}/#{filename}"))
      File.open("#{view_path}/#{filename}", 'w+') { |f| f.write('the default template') }
      ActionView::Template.new(filename, view_path)
    end

    def update_template_file(filename)
      File.open(filename, 'w+') { |f| f.write('the updated template') }
    end

    def view_paths(path = "public/themes/theme-1/templates")
      create_template
      paths = ActionView::PathSet.new
      # paths << ActionView::DynamicEagerPath.new("#{RAILS_ROOT}/tmp/themes/#{path}")
      paths << "#{RAILS_ROOT}/tmp/themes/#{path}"
    end

    def set_theme_file_modified_at(filename, time)
      RR.stub(File).mtime(filename).returns time
    end
end