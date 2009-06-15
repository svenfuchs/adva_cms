require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

require File.expand_path(File.dirname(__FILE__) + '/../init')

class ActionController::IntegrationTest
  
  def allow_anonymous_commenting
    @user = User.anonymous
    stub(User).anonymous.returns(@user)
    stub(@user).has_role?.returns(true)
  end
  
  def disable_spam_filtering
    options = { }
    @site.spam_options = options
    stub(@site).spam_engine.returns nil
    @site.save!
    assert @site.spam_options == options
  end
  
  def set_ham_options_to_authenticated
    options = {:default => { :ham => "authenticated" } }
    @site.spam_options = options
    @site.save!
    assert @site.spam_options == options
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
  
  def stub_akismet_service(options = {})
    @akismet = @site.spam_engine.last
    @viking = Viking::Akismet.new({})
    stub(Viking).connect.returns(@viking)
    stub(@viking).check_comment.returns(options)
    stub(@akismet).backend.returns(@viking)
  end
  
  def stub_defensio_service(options = {})
    @defensio = @site.spam_engine.last
    @viking = Viking::Defensio.new({})
    stub(Viking).connect.returns(@viking)
    stub(@viking).check_comment.returns(options)
    stub(@defensio).backend.returns(@viking)
  end
end