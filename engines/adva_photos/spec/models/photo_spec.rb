require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  include Matchers::ClassExtensions
  
  before :each do
    @photo = Photo.new
  end
  
  describe "class extensions:" do
    it "acts as a taggable" do
      Photo.should act_as_taggable
    end

    it "acts as a role context for the author role" do
      Photo.should act_as_role_context(:roles => :author)
    end

    it "acts as a commentable" do
      Photo.should act_as_commentable
    end

    it "has a comments counter" do
      Photo.should have_counter(:comments)
    end

    it "has a permalink generated from the title" do
      Photo.should have_a_permalink(:title)
    end
    
    it "is configured to save a new version when the title attribute changes" do
      Photo.tracked_attributes.should == ["title"]
    end

    it "is configured to save up to 5 versions" do
      Photo.max_version_limit.should == 5
    end

    it "ignores the column cached_tag_list" do
      defaults = ["id", "type", "version", "lock_version", "versioned_type"]
      Photo.non_versioned_columns.should == defaults + ["cached_tag_list"]
    end
  end
  
  describe "associations" do
    it "belongs to a section" do
      @photo.should belong_to(:section)
    end

    it "belongs to an author" do
      @photo.should belong_to(:author)
    end

    it "has many sets" # do
    #   @photo.should have_many(:sets)
    # end

    it "has many set_assignments" # do
    #   @photo.should have_many(:set_assignments)
    # end
  end
  
  describe "validations" do
    it "validates presence of a title" do
      @photo.should validate_presence_of(:title)
    end

    it "validates presence of an author (through belongs_to_author)" do
      @photo.should validate_presence_of(:author)
    end

    it "validates that the author is valid (through belongs_to_author)" do
      @photo.stub!(:author).and_return(User.new)
      @photo.author.email = nil
      @photo.valid?.should be_false
    end

    it "validates the uniqueness of the permalink per section" do
      @photo.should validate_uniqueness_of(:permalink)
    end
  end
end