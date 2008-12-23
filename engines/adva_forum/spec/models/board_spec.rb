require File.dirname(__FILE__) + '/../spec_helper'

describe Board do
  include Stubby, Matchers::ClassExtensions
  include FactoryScenario
  
  before :each do
    Site.delete_all
    @site   = Factory :site
    @forum  = Factory :forum, :site => @site
    @user   = Factory :user
    @board  = Board.new(:title => 'Test board', :site => @site, :section => @forum)
  end

  it "acts as a commentable" do
    Board.should act_as_commentable
  end
  
  it "acts as role context with a Section as a parent" do
    Board.should act_as_role_context(:parent => Section)
  end

  it "has a topics counter" do
    Board.should have_counter(:topics)
  end
  
  it "delegates topics_per_page to the section" do
    @forum.topics_per_page = 9
    @board.topics_per_page.should == @forum.topics_per_page
  end
  
  it "delegates comments_per_page to the section" do
    @forum.comments_per_page = 9
    @board.comments_per_page.should == @forum.comments_per_page
  end

  describe "associations" do
    it "belongs to a site" do
      @board.should belong_to(:site)
    end
    
    it "belongs to a section" do
      @board.should belong_to(:section)
    end
    
    it "has many topics" do
      @board.should have_many(:topics)
    end
    
    it "belongs to last_author" do
      @board.should belong_to(:last_author)
    end

    it "has one recent topic" do
      @board.should have_one(:recent_topic)
    end

    it "has one recent comment" do
      @board.should have_one(:recent_comment)
    end

    it "#recent_topic returns the most recent topic" do
      factory_scenario :board_with_topics
      @board.recent_topic.should == @recent_topic
    end

    it "#recent_comment returns the most recent comment" do
      stub_scenario :board_with_three_comments
      @board.recent_comment.should == @latest_comment
    end

    it "has a topics counter" do
      @board.should have_one(:topics_counter)
    end

    it "has a comments counter" do
      @board.should have_one(:comments_counter)
    end
  end

  describe "callbacks" do
    # it "initializes the topics counter after create" do
    #   Board.after_create.should include(:set_topics_count)
    # end
    # 
    # it "initializes the comments counter after create" do
    #   Board.after_create.should include(:set_comments_count)
    # end
    
    it "sets the site before validation" do
      Board.before_validation.should include(:set_site)
    end
  end

  # describe '#after_topic_update' do
  #   before :each do
  #     @board.topics.stub!(:count)
  #     @board.comments.stub!(:count)
  #     @board.stub!(:topics_count).and_return stub_counter
  #     @board.stub!(:comments_count).and_return stub_counter
  #   end
  #
  #   it "updates the topics counter" do
  #     @board.topics_count.should_receive(:set).any_number_of_times
  #     @board.send :after_topic_update, @topic
  #   end
  #
  #   it "updates the comments counter" do
  #     @board.comments_count.should_receive(:set).any_number_of_times
  #     @board.send :after_topic_update, @topic
  #   end
  # end

  describe "counters on a board with three comments on one topic" do
    before :each do
      stub_scenario :board_with_three_comments
    end

    it "should have one board" do
      @forum.boards.count.should == 1
    end

    it "should have one topic" do
      @board.topics.count.should == 1
    end

    it "should have three comments" do
      @board.comments.count.should == 3
    end

    it "should have counted the comments" do
      @board.comments_count.should == 3
    end

    it "should have counted the topics" do
      @board.topics_count.should == 1
    end
  end

  describe "cached attributes on a board with three comments on one topic" do
    before :each do
      stub_scenario :board_with_three_comments
    end

    it "should have last_comment_id set" do
      @board.last_comment_id.should == @latest_comment.id
    end

    it "should have last_updated_at set" do
      @board.last_updated_at.should == @one_day_ago
    end

    it "should have last_author set" do
      @board.last_author.should == stub_user
    end
  end
  
  describe "methods" do
    describe "public" do
      describe "#after_comment_update_with_board" do
        before :each do
          @comment = @board.comments.build
        end
        
        it "updates the last_updated_at, last_comment_id and last_author fields" do
          fields = {:last_updated_at => @comment.created_at, :last_comment_id => @comment.id, 
                    :last_author => @comment.author}
          @board.should_receive(:update_attributes!).with(fields)
          
          @board.after_comment_update_with_board(@comment)
        end
        
        it "calls destroy on itself if comment is nil" do # hu?
          @board.should_receive(:destroy)
          @board.after_comment_update_with_board(nil)
        end
      end
    end
    
    describe "protected" do
      describe "#author" do
        it "returns section as owner of board" do
          @board.send(:owner).should == @board.section
        end
      end
    
      describe "#set_site" do
        before :each do
          @board.site = nil
        end
      
        it "sets the boards site from section.site" do
          @board.send(:set_site)
          @board.site.should == @forum.site
        end
      
        it "does not set the site for board if board does not have section" do
          @board.section = nil
          @board.send(:set_site)
          @board.site.should be_nil
        end
      end
    end
  end
end