require File.dirname(__FILE__) + '/../spec_helper'

describe Theme::File do
  before :each do
    @theme_dir = "#{Theme.root_dir}/themes/site-1/theme_1/templates"
    @theme_file = "#{@theme_dir}/foo.html.erb"

    FileUtils.mkdir_p(@theme_dir) unless File.exists?(@theme_dir)
    FileUtils.touch(@theme_file) unless File.exists?(@theme_file)
    
    @template = ActionView::Template.new(@theme_file)
    @template.stub!(:relative_path).and_return('themes/site-1/theme_1/templates/foo.html.erb')
    
    @compiled_template_method_name = "_run_erb_#{@template.method_segment}"
  end
  
  after :each do
    FileUtils.rm_r(@theme_dir)
    ActionView::Base::CompiledTemplates.instance_methods(false).each do |method|
      ActionView::Base::CompiledTemplates.send(:remove_method, method)
    end
  end
  
  it "caches the compile time" do
    was_compiled!
    @template.compile_times.keys.should include(@template.theme_path)
  end
  
  it "compiles the template if it has not been compiled yet" do
    compiled_template_methods.should be_empty
    compile
    compiled_template_methods.should include(@compiled_template_method_name)
  end
  
  it "does not compile the template if has already been compiled before and the theme has not been touched" do
    was_compiled!
    File.stub!(:mtime).and_return(Time.now - 1.second)
    @template.should_not_receive(:compile!)
    compile
  end
  
  it "compiles the template if has already been compiled before but the theme has been touched meanwhile" do
    was_compiled!
    File.stub!(:mtime).and_return(Time.now + 1.second)
    @template.should_receive(:compile!)
    compile
  end
  
  it "#theme_modified_since_compile? returns true if the theme was touched after the template was compiled" do
    was_compiled!
    File.stub!(:mtime).and_return(Time.now + 1.second)
    @template.theme_modified_since_compile?.should be_true
  end
  
  def was_compiled!
    @template.send(:compile!, @template.send(:method_name, {}), {})
  end
  
  def compile
    @template.send :compile, {}
  end
  
  def compiled_template_methods
    ActionView::Base::CompiledTemplates.instance_methods(false)
  end
end
