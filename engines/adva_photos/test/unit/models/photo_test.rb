require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PhotoTest < ActiveSupport::TestCase
  include PhotoTestHelper

  def setup
    super
    @photo = Photo.first
    @published_photo = Photo.find_by_title('a published photo')
  end
  
  # Class extensions
  
  test "acts as a taggable" do
    Photo.should act_as_taggable
  end

  test "acts as a role context for the author role" do
    Photo.should act_as_role_context(:roles => :author)
  end

  test "acts as a commentable" do
    Photo.should act_as_commentable
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

  test "has many category_assignments" do
    @photo.should have_many(:category_assignments)
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
    @photo.valid?.should be_false
  end
  
  # Callbacks
  
  test "sets the site from the section before validation" do
    Photo.before_validation.should include(:set_site)
  end
    
  # Public methods
  
  # draft?
  
  test '#draft?, returns true when the photo has not published_at date' do
    @photo.draft?.should be_true
  end

  test '#draft?, returns false when the photo has a published_at date' do
    @published_photo.draft?.should be_false
  end
  
  # published?
  
  test "#published?, returns true when published_at equals the current time" do
    @published_photo.update_attribute(:published_at, Time.now)
    @published_photo.published?.should be_true
  end

  test "#published?, returns true when published_at is a past date" do
    @published_photo.published?.should be_true
  end

  test "#published?, returns false when published_at is a future date" do
    @published_photo.update_attribute(:published_at, 1.day.from_now)
    @published_photo.published?.should be_false
  end

  test "#published?, returns false when published_at is nil" do
    @photo.published?.should be_false
  end
  
  # pending?
  
  test "#pending?, returns true when photo is not published" do
    @photo.pending?.should be_true
  end
  
  test "#pending?, returns false when photo is published" do
    @published_photo.pending?.should be_false
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
    photo = Photo.new :data_file_name => 'rails.png'
    photo.filename.should == 'rails.png'
  end
  
  test "filename inserts the style between basename and extension for other styles" do
    photo = Photo.new :data_file_name => 'rails.png'
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
    [:medium, :thumb, :tiny].each do |style|
      photo.path(style).should be_file
    end
  end if system('which convert') # umm, would this work on windows?
end