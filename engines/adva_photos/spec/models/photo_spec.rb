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
  end
  
  describe "associations" do
    it "belongs to a section" do
      @photo.should belong_to(:section)
    end

    it "belongs to an author" do
      @photo.should belong_to(:author)
    end
    
    it "has many sets" do
      @photo.should have_many(:sets)
    end

    it "has many category_assignments" do
      @photo.should have_many(:category_assignments)
    end
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
  end
  
  describe "callbacks:" do
    it "sets the position before create" do
      Photo.before_create.should include(:set_position)
    end
    
    it "sets the from parent before validation on create" do
      Photo.before_validation_on_create.should include(:set_values_from_parent)
    end
  end
  
  describe "methods" do
    describe '#draft?' do
      it 'returns true when the photo has not published_at date' do
        @photo.draft?.should be_true
      end
  
      it 'returns false when the photo has a published_at date' do
        @photo.stub!(:published_at).and_return Time.now
        @photo.draft?.should be_false
      end
    end
    
    describe '#published?' do
      it "returns true when published_at equals the current time" do
        @photo.should_receive(:published_at).any_number_of_times.and_return(Time.zone.now)
        @photo.published?.should be_true
      end
  
      it "returns true  when published_at is a past date" do
        @photo.should_receive(:published_at).any_number_of_times.and_return(1.day.ago)
        @photo.published?.should be_true
      end
  
      it "returns false when published_at is a future date" do
        @photo.should_receive(:published_at).any_number_of_times.and_return(1.day.from_now)
        @photo.published?.should be_false
      end
  
      it "returns false when published_at is nil" do
        @photo.should_receive(:published_at).any_number_of_times.and_return(nil)
        @photo.published?.should be_false
      end
    end
    
    describe '#pending?' do
      it "returns true when photo is not published" do
        @photo.should_receive(:published?).and_return false
        @photo.pending?.should be_true
      end
      
      it "returns false when photo is published" do
        @photo.should_receive(:published?).and_return true
        @photo.pending?.should be_false
      end
    end
    
    describe '#state?' do
      it "returns :pending when photo is pending" do
        @photo.should_receive(:pending?).and_return true
        @photo.state.should == :pending
      end
      
      it "returns :published when photo is not pending" do
        @photo.should_receive(:pending?).and_return false
        @photo.state.should == :published
      end
    end
  end
end