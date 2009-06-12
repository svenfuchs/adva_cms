require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module IntegrationTests
  class SpamControlTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @blog = @site.sections.first
      @article = @blog.articles.first
      
      # stub to say: " :'comments_create' => :anonymous " role
      @user = User.anonymous
      stub(User).anonymous.returns(@user)
      stub(@user).has_role?.returns(true)
    end

    test "A site w/ default filter and the ham option not set does not approve an anonymous comment" do
      set_ham_options_to_none
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end

    test "A site w/ default filter and the ham option set to all approves an anonymous comment" do
      set_ham_options_to_all
      visit_the_article
      fill_and_post_the_comment_form
      assert Comment.last.approved?
    end

    test "A site w/ default filter and the ham option set to authorized does not approve an anonymous comment" do
      set_ham_options_to_authenticated
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end

    test "A site w/ default filter and the ham option set to authorized approves an authenticated comment" do
      set_ham_options_to_authenticated
      login_as_user
      visit_the_article
      fill_and_post_the_comment_form_as_authenticated
      assert Comment.last.approved
    end

    test "A site w/ Akismet filter returnin 'spam' does not approve a comment (when default filter is set to 'none')" do
      set_akismet_as_spam_engine
      akismet_mark_as_spam_stubbing
      
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end

    test "A site w/ Akismet filter returning 'ham' approves a comment (when default filter is set to 'none')" do
      set_akismet_as_spam_engine
      akismet_mark_as_ham_stubbing
      
      visit_the_article
      fill_and_post_the_comment_form
      assert Comment.last.approved?
    end

    test "A site w/ Defensio filter returnin 'spam' does not approve a comment (when default filter is set to 'none')" do
      set_defensio_as_spam_engine
      defensio_mark_as_spam_stubbing
      
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end

    test "A site w/ Defensio filter returning 'ham' approves a comment (when default filter is set to 'none')" do
      set_defensio_as_spam_engine
      defensio_mark_as_ham_stubbing
      
      visit_the_article
      fill_and_post_the_comment_form
      assert Comment.last.approved?
    end
    
    def set_ham_options_to_none
      options = {:default => { :ham => "none" } }
      @site.spam_options = options
      @site.save!
      assert @site.spam_options == options
    end
    
    def set_ham_options_to_all
      options = {:default => { :ham => "all" } }
      @site.spam_options = options
      @site.save!
      assert @site.spam_options == options
    end
    
    def set_ham_options_to_authenticated
      options = {:default => { :ham => "authenticated" } }
      @site.spam_options = options
      @site.save!
      assert @site.spam_options == options
    end
    
    def set_akismet_as_spam_engine
      options = {:filters => "akismet", :default => { :ham => "none" },
                                        :akismet => { :key => 'akismet key', :url => 'akismet url', :priority => 2 } }
                                        
      @site.spam_options = options
      @site.save!
      
      assert @site.spam_options == options
    end
    
    def set_defensio_as_spam_engine
      options = {:filters => "defensio", :default => { :ham => "none" },
                                         :defensio => { :key => 'defensio key', :url => 'defensio url', :priority => 2 } }
                                        
      @site.spam_options = options
      @site.save!
      
      assert @site.spam_options == options
    end
    
    def akismet_mark_as_spam_stubbing
      @akismet = @site.spam_engine.last
      @viking = Viking::Akismet.new({})           # stub the akismet backend
      stub(Viking).connect.returns(@viking) 
      stub(@viking).check_comment.returns false   # return comment result as a spam
      stub(@akismet).backend.returns(@viking)     # use the stubbed viking service
    end
    
    def akismet_mark_as_ham_stubbing
      @akismet = @site.spam_engine.last
      @viking = Viking::Akismet.new({})           # stub the akismet backend
      stub(Viking).connect.returns(@viking) 
      stub(@viking).check_comment.returns true    # return comment result as a ham
      stub(@akismet).backend.returns(@viking)     # use the stubbed viking service
    end
    
    def defensio_mark_as_spam_stubbing
      @defensio = @site.spam_engine.last
      @viking = Viking::Defensio.new({})          # stub the defensio backend
      stub(Viking).connect.returns(@viking) 
      stub(@viking).check_comment.returns({ :spam => true })   # return comment result as a spam
      stub(@defensio).backend.returns(@viking)    # use the stubbed viking service
    end
    
    def defensio_mark_as_ham_stubbing
      @defensio = @site.spam_engine.last
      @viking = Viking::Defensio.new({})           # stub the defensio backend
      stub(Viking).connect.returns(@viking) 
      stub(@viking).check_comment.returns({ :spam => false })   # return comment result as a ham
      stub(@defensio).backend.returns(@viking)    # use the stubbed viking service
    end
    
    def visit_the_article
      get "/#{@blog.permalink}/2008/1/1/#{@article.permalink}"
      assert_template 'articles/show'
    end
    
    def fill_and_post_the_comment_form
      comment_count = Comment.count
      
      fill_in 'Name',         :with => 'Anonymous'
      fill_in 'E-mail',       :with => 'anonymous@anonymous.org'
      fill_in 'comment_body', :with => 'This is an anonymous message'
      click_button 'Submit comment'
      
      assert Comment.count == comment_count + 1
    end
    
    def fill_and_post_the_comment_form_as_authenticated
      comment_count = Comment.count
      
      fill_in 'comment_body', :with => 'authenticated comment'
      click_button 'Submit comment'
      
      assert Comment.count == comment_count + 1
    end
  end
end