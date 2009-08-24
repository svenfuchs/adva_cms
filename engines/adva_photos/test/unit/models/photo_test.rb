require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PhotoTest < ActiveSupport::TestCase
  include PhotoTestHelper

  def setup
    super
    @photo = Photo.find_by_title('a photo')
    @site = @photo.section.site
    @published_photo = Photo.find_by_title('a published photo')
  end

  # Class extensions

  test "acts as a taggable" do
    Photo.should act_as_taggable
  end

  test "acts as a role context for the author role" do
    Photo.should act_as_role_context(:roles => :author)
  end

  test "has many comments" do
    Photo.should have_many_comments
  end

  test "has a comments counter" do
    Photo.should have_counter(:comments)
  end

  # Associations

  test "belongs to a section" do
    @photo.should belong_to(:section)
  end

  test "belongs to an author" do
    @photo.should belong_to(:author)
  end

  test "has many sets" do
    @photo.should have_many(:sets)
  end

  test "has many categorizations" do
    @photo.should have_many(:categorizations)
  end

  # Validations

  test "validates presence of a title" do
    @photo.should validate_presence_of(:title)
  end

  test "validates presence of an author (through belongs_to_author)" do
    @photo.should validate_presence_of(:author)
  end

  test "validates that the author is valid (through belongs_to_author)" do
    @photo.author.email = nil
    @photo.should_not be_valid
  end

  test "does not change the filename if the file does not exist" do
    create_photo.path.should == "#{Photo.root_dir}/sites/site-#{@site.id}/photos/rails.png"
  end

  test "appends an integer to basename to ensure a unique filename if the file exists" do
    dirname = "#{Photo.root_dir}/sites/site-#{@site.id}/photos"
    FileUtils.mkdir_p dirname
    create_photo.path.should == "#{dirname}/rails.png"
    create_photo.path.should == "#{dirname}/rails.1.png"
  end

  # Callbacks

  # Public methods

  # draft?

  test '#draft?, returns true when the photo has a published_at date' do
    @photo.should be_draft
  end

  test '#draft?, returns false when the photo does not have a published_at date' do
    @published_photo.should_not be_draft
  end

  # published?

  test "#published?, returns true when published_at equals the current time" do
    @published_photo.update_attribute(:published_at, Time.now)
    @published_photo.should be_published
  end

  test "#published?, returns true when published_at is a past date" do
    @published_photo.should be_published
  end

  test "#published?, returns false when published_at is a future date" do
    @published_photo.update_attribute(:published_at, 1.day.from_now)
    @published_photo.should_not be_published
  end

  test "#published?, returns false when published_at is nil" do
    @photo.should_not be_published
  end

  # pending?

  test "#pending?, returns true when photo is not published" do
    @photo.should be_pending
  end

  test "#pending?, returns false when photo is published" do
    @published_photo.should_not be_pending
  end

  # state?

  test "#state?, returns :pending when photo is pending" do
    @photo.state.should == :pending
  end

  test "#state?, returns :published when photo is not pending" do
    @published_photo.state.should == :published
  end

  # filename

  test "filename returns original data_file_name for :original style" do
    photo = Photo.new(:data_file_name => 'rails.png')
    photo.filename.should == 'rails.png'
  end

  test "filename inserts the style between basename and extension for other styles" do
    photo = Photo.new(:data_file_name => 'rails.png')
    photo.filename(:thumb).should == 'rails.thumb.png'
  end

  # Creation/Paperclip

  test "creates a valid photo" do
    photo = create_photo
    photo.should be_valid
    photo.path.should be_file
  end

  test "creates medium, thumb and tiny variants if ImageMagick is installed" do
    photo = create_photo
    [:large, :thumb, :tiny].each do |style|
      photo.path(style).should be_file
    end
  end unless `which convert`.blank?
end