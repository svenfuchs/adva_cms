require File.dirname(__FILE__) + '/../../test_helper'
require "hpricot"

class AdvaIssueImageTest < ActiveSupport::TestCase
  def setup
    @issue_image = Adva::IssueImage.new(valid_img)
    super
  end

  def teardown
    super
  end

  def valid_img
    "<img src=\"http://localhost/files/test.1.jpg?12345\" alt=\"Test\" />"
  end

  test "#initialize should accept html as a string" do
    img = Adva::IssueImage.new(valid_img)
    img.alt.should == "Test"
  end

  test "#initialize should accept html as a hpricot img element" do
    hpricot_img_element = Hpricot(valid_img).at("img")
    img = Adva::IssueImage.new(hpricot_img_element)
    img.alt.should == "Test"
  end

  test "#initialize should raise error when html does not have img element" do
    lambda { Adva::IssueImage.new(valid_img) }.should_not raise_error(Adva::IssueImage::MissingValidImageElement)
    lambda { Adva::IssueImage.new("invalid html img tag") }.should raise_error(Adva::IssueImage::MissingValidImageElement)
    lambda { Adva::IssueImage.new("<img alt=\"without src\"") }.should raise_error(Adva::IssueImage::MissingValidImageElement)
  end

  test "#initialize should raise error when src url is not absoulte" do
    lambda { Adva::IssueImage.new(valid) }.should_not raise_error(Adva::IssueImage::NotAbsoluteUri)
    lambda { Adva::IssueImage.new("<img src='/not_absoulte' />") }.should raise_error(Adva::IssueImage::NotAbsoluteUri)
  end

  test "#initialize should raise error when img src does not have filename" do
    lambda { Adva::IssueImage.new(valid_img) }.should_not raise_error(Adva::IssueImage::MissingImageFilename)
    lambda { Adva::IssueImage.new("<img src='http://example.com' />") }.should raise_error(Adva::IssueImage::MissingImageFilename)
  end

  test "#initialize should raise error when img src does not have valid file extension" do
    lambda { Adva::IssueImage.new(valid_img) }.should_not raise_error(Adva::IssueImage::WrongImageExtension)
    lambda { Adva::IssueImage.new("<img src='http://example.com/img_wrong_extension.exe' />") }.should
      raise_error(Adva::IssueImage::WrongImageExtension)
  end

  test "#initialize errors should be logged" do
    mock(RAILS_DEFAULT_LOGGER).debug(is_a(String))
    Adva::IssueImage.parse("<img />")
  end

  test "#alt should return alt attribute" do
    @issue_image.alt.should == "Test"
  end

  test "#filename should return base filename" do
    @issue_image.filename.should == "test.1.jpg"
  end

  test "#valid_extension should return true when extension is valid" do
    @issue_image.should have_valid_extension
    mock(@issue_image).extension { "false_extension" }
    @issue_image.should_not have_valid_extension
  end

  test "#uri should return uri string" do
    @issue_image.uri.should == "http://localhost/files/test.1.jpg?12345"
  end

  test "#file should return file string" do
    stub(OpenURI).open_uri {Tempfile.new("")}
    @issue_image.file.should be_a(String)
  end

  test "#file errors should be logged" do
    stub(Adva::IssueImage).open { raise OpenURI::HTTPError }
    mock(RAILS_DEFAULT_LOGGER).debug(is_a(String))
    Adva::IssueImage.new("<img src='http://example.com/no_file.jpg' />").file
  end

  test "#content_type should call open-uri content_type and return content type string" do
    @tempfile = ""
    mock(@tempfile).content_type { "image/jpeg" }
    stub(OpenURI).open_uri { @tempfile }
    @issue_image.content_type.should == "image/jpeg"
  end

  test "#cid should return unique content-id" do
    cid = "unique content id"
    stub(TMail).new_message_id { cid }
    @issue_image.cid.should == cid
  end

  test "#cid_plain should return unique content-id without <>" do
    cid = "<4a2687159da4c_1e6c..fdbe998d616b@test.tmail>"
    stub(TMail).new_message_id { cid }
    @issue_image.cid_plain.should == "4a2687159da4c_1e6c..fdbe998d616b@test.tmail"
  end
end

class AdvaIssueImageClassTest < ActiveSupport::TestCase
  def setup
    super
    body_html =
    <<-html
      <img alt=\"Test Name\" src=\"http://localhost:3000/assets/test.1.jpg?1243597104\" /></a>
      <img alt=\"Test PNG Name\" src=\"http://localhost:3000/assets/test_png.1.png?1243597104\" /></a>
      <img alt=\"Test gif Name\" src=\"http://localhost:3000/assets/test_gif.1.gif\" /></a>
      <img alt=\"Test wrong extension\" src=\"http://localhost:3000/assets/wrong_extension.rb\" /></a>
    html
    @issue_images = Adva::IssueImage.parse(body_html)
  end

  def teardown
    super
  end

  test "#parse should return IssueImage instances" do
    @issue_images.first.should be_a(Adva::IssueImage)
    @issue_images.size.should == 3
  end

  test "#parse should not return IssueImage instances when faile extension is wrong" do
    @issue_images.each do |image|
      unless %w[png jpg gif].include?(image.extension)
        "Wrong extension of #{image.filename}".should == true # huh???
      end
    end
  end

  test "#parse should return empty array  when html is empty" do
    Adva::IssueImage.parse("").should == []
  end

  test "#valid_extensions should return array of valid extensions" do
    Adva::IssueImage.valid_extensions.should be_a(Array)
  end
end
