require File.dirname(__FILE__) + '/../../test_helper'
# RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../../../../../../..") unless defined?(RAILS_ROOT)
# 
# require 'rubygems'
# require 'active_support'
# require 'active_support/test_case'
# require 'action_controller'
# require File.expand_path(File.dirname(__FILE__) + '/../../../../../test/rr/lib/rr')
# require File.expand_path(File.dirname(__FILE__) + '/../../../lib/theme_support/compiled_template_expiration')

class Theme
  def self.root_dir
    "#{RAILS_ROOT}/tmp"
  end
end unless defined?(Theme)

class CompiledTemplateExpirationTest < ActiveSupport::TestCase
  def setup
    super
    @now = Time.now
    RR.stub(Time).now.returns @now
  end
  
  def teardown
    super
    FileUtils.rm_r "#{RAILS_ROOT}/tmp/themes" rescue Errno::ENOENT
    ActionView::Base::CompiledTemplates.instance_methods(false).each do |m|
      ActionView::Base::CompiledTemplates.send(:remove_method, m) if m =~ /^_run_/
    end
  end
  
  test "theme_path returns the theme_path segment if the template is a theme template (single-site mode)" do
    template = create_template("public/themes/theme-1/templates", "layouts/default.html.erb")
    assert_equal 'themes/theme-1', template.theme_path
  end
  
  test "theme_path returns the theme_path segment if the template is a theme template (multi-site mode)" do
    template = create_template("public/themes/site-1/theme-1/templates", "layouts/default.html.erb")
    assert_equal 'themes/site-1/theme-1', template.theme_path
  end
  
  test "theme_modified_since_compile? is true if the theme dir has been touched since the template has been compiled" do
    template = create_template
    set_template_compiled_at template, @now - 1
    set_theme_modified_at @now
    assert template.theme_modified_since_compile?
  end
  
  test "theme_modified_since_compile? is false if the theme dir has not been touched since the template has been compiled" do
    template = create_template
    set_template_compiled_at template, @now
    set_theme_modified_at @now - 1
    assert !template.theme_modified_since_compile?
  end
  
  test "theme_modified_since_compile? is false if the template has not been compiled yet" do
    template = create_template
    set_template_compiled_at template, nil
    set_theme_modified_at @now
    assert !template.theme_modified_since_compile?
  end
  
  test "theme_modified_since_compile? is false if theme directory does not exist" do
    template = create_template
    set_template_compiled_at template, nil
    FileUtils.rm_r "#{RAILS_ROOT}/tmp/themes"
    assert !template.theme_modified_since_compile?
  end
  
  test "expire_compiled_theme_templates! expires compiled theme templates" do
    template = create_template
    template.send :compile, {}
    template.expire_compiled_theme_templates!
    assert ActionView::Base::CompiledTemplates.instance_methods(false).empty?
  end
  
  test "expire_compiled_theme_templates! does not expire other compiled templates" do
    template = create_template 'other/path/to/views'
    template.send :compile, {}
    template.expire_compiled_theme_templates!
    assert !ActionView::Base::CompiledTemplates.instance_methods(false).empty?
  end

  def create_template(view_path = "public/themes/theme-1/templates", filename = "layouts/default.html.erb")
    view_path = "#{RAILS_ROOT}/tmp/themes/#{view_path}"
    FileUtils.mkdir_p(File.dirname("#{view_path}/#{filename}"))
    FileUtils.touch("#{view_path}/#{filename}")
    ActionView::Template.new(filename, view_path)
  end
  
  def set_template_compiled_at(template, time)
    ActionView::Template.compile_times[template.theme_path] = time
  end
  
  def set_theme_modified_at(time)
    RR.stub(File).mtime.returns time
  end
end