require File.dirname(__FILE__) + '/../../test_helper'

class AdvaIssueImageTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.find_by_name("site with newsletter")
    @newsletter = @site.newsletters.first
    @issue = @newsletter.issues.first
    @user = @site.users.first
    @issue.body = 
    <<-html
      <img alt=\"Test Name\" src=\"http://localhost:3000/assets/test.1.jpg?1243597104\" /></a>
      <img alt=\"Test PNG Name\" src=\"http://localhost:3000/assets/test_png.1.png?1243597104\" /></a>
      <img alt=\"Test gif Name\" src=\"http://localhost:3000/assets/test_gif.1.gif\" /></a>
      <img alt=\"Test wrong extension\" src=\"http://localhost:3000/assets/wrong_extension.rb\" /></a>
    html
    @issue.save
    @issue_images = Adva::IssueImage.parse(@issue.body_html)
    @issue_image = @issue_images.first
  end

  def teardown
    super
  end
  
# class methods
  test "#parse should return IssueImage instances" do
    @issue_images.first.class.should == Adva::IssueImage
    @issue_images.size.should == 3
  end
  
  test "#parse should not return IssueImage instances when faile extension is wrong" do
    @issue_images.each do |image|
      unless %w[png jpg gif].include?(image.extension)
        "Wrong extension of #{image.filename}".should == true
      end
    end
  end
  
  test "#parse should return empty array  when html is empty" do
    Adva::IssueImage.parse("").should == []
  end
  
  test "#valid_extensions should return array of valid extensions" do
    Adva::IssueImage.valid_extensions.class.should == Array
  end
  
# instance methods
  test "#initialize should raise error when html does not have img element" do
    lambda { Adva::IssueImage.new("wrong html without img element") }.should raise_error(Adva::IssueImage::MissingImgElement)
  end
  
  test "#initialize should raise error when img src does not have filename" do
    lambda { Adva::IssueImage.new("<img />") }.should raise_error(Adva::IssueImage::MissingImgFilename)
  end
  
  test "#initialize should raise error when src url is not absoulte" do
    lambda { Adva::IssueImage.new("<img src='/not_absoulte' />") }.should raise_error(Adva::IssueImage::NotAbsoluteUri)
  end
  
  test "#initialize errors should be logged" do
    mock(RAILS_DEFAULT_LOGGER).debug(is_a(String))
    Adva::IssueImage.parse("<img />")
  end

  test "#alt should return alt attribute" do
    @issue_image.alt.should == "Test Name"
  end
  
  test "#filename should return base filename" do
    @issue_image.filename.should == "test.1.jpg"
  end
  
  test "#valid_extension should return true when extension is valid" do
    @issue_image.valid_extension?.should == true
    mock(@issue_image).extension {"false_extension"}
    @issue_image.valid_extension?.should == false
  end
  
  test "#uri should return uri" do
    @issue_image.uri.should == "http://localhost:3000/assets/test.1.jpg?1243597104"
  end
  
  test "#file should return string" do
    stub(OpenURI).open_uri {Tempfile.new("")}
    @issue_image.file.class.should == String
  end
  
  test "#file errors should be logged" do
    mock(RAILS_DEFAULT_LOGGER).debug(is_a(String))
    Adva::IssueImage.new("<img src='http://example.com/no_file.jpg' />").file
  end
  
  test "#content_type should call open-uri content_type and return content type string" do
    @tempfile = ""
    mock(@tempfile).content_type {"image/jpeg"}
    stub(OpenURI).open_uri {@tempfile}
    @issue_image.content_type.should == "image/jpeg"
  end
  
  test "#cid should return unique content-id" do
    cid = "unique content id"
    stub(TMail).new_message_id {cid}
    @issue_image.cid.should == cid
  end
  
  test "#cid_plain should return unique content-id without <>" do
    cid = "<4a2687159da4c_1e6c..fdbe998d616b@test.tmail>"
    stub(TMail).new_message_id {cid}
    @issue_image.cid_plain.should == "4a2687159da4c_1e6c..fdbe998d616b@test.tmail"
  end
end
