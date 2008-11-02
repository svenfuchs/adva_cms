dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

describe "install.rb" do
  include FileUtils

  before do
    @rails_root = "#{Dir.tmpdir}/cachable_flash_#{Time.now.to_f}"
    Object.send(:remove_const, :RAILS_ROOT) if Object.const_defined?(:RAILS_ROOT)
    Object.const_set(:RAILS_ROOT, @rails_root)

    @stdout = StringIO.new("")
    $stdout = @stdout

    @js_dir = "#{@rails_root}/public/javascripts"
    FileUtils.mkdir_p(@js_dir)
    @install_path = "#{File.dirname(__FILE__)}/../../install.rb"
  end

  after do
    $stdout = STDOUT
  end

  describe "when project does not have json.js" do
    it "installs javascript files including json.js" do
      File.exists?("#{@js_dir}/flash.js").should be_false
      File.exists?("#{@js_dir}/json.js").should be_false
      File.exists?("#{@js_dir}/cookie.js").should be_false
      load(@install_path)
      File.exists?("#{@js_dir}/flash.js").should be_true
      File.exists?("#{@js_dir}/json.js").should be_true
      File.exists?("#{@js_dir}/cookie.js").should be_true
    end
  end
  
  describe "when project has json.js" do
    it "does not overwrite the existing json.js and installs other javascript files" do
      File.open("#{@js_dir}/json.js", "w") do |f|
        f.write "Original json.js"
      end
      File.exists?("#{@js_dir}/json.js").should be_true
      File.exists?("#{@js_dir}/flash.js").should be_false
      File.exists?("#{@js_dir}/cookie.js").should be_false
      load(@install_path)
      File.exists?("#{@js_dir}/flash.js").should be_true
      File.exists?("#{@js_dir}/cookie.js").should be_true
      File.exists?("#{@js_dir}/json.js").should be_true
      File.read("#{@js_dir}/json.js").should == "Original json.js"
    end
  end

  describe "when project has cookie.js" do
    it "does not overwrite the existing cookie.js" do
      File.open("#{@js_dir}/cookie.js", "w") do |f|
        f.write "Original cookie.js"
      end
      File.exists?("#{@js_dir}/json.js").should be_false
      File.exists?("#{@js_dir}/flash.js").should be_false
      File.exists?("#{@js_dir}/cookie.js").should be_true
      load(@install_path)
      File.exists?("#{@js_dir}/flash.js").should be_true
      File.exists?("#{@js_dir}/json.js").should be_true
      File.exists?("#{@js_dir}/cookie.js").should be_true
      File.read("#{@js_dir}/cookie.js").should == "Original cookie.js"
    end
  end
end
