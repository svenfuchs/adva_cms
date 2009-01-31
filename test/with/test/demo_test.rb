require File.dirname(__FILE__) + '/helper'

class DemoTest < Test::Unit::TestCase
  def setup
    Target.reset
  end
  
  def test_something
    With.share(:caching) { before { @caching = true } }
    With.share(:observers) { before { @observers = true } }
    With.share(:login_as_admin) { before { @controller.current_user = User.new(true) } }
    With.share(:login_as_user) { before { @controller.current_user = User.new(false) } }
    With.share(:no_login) { before { @controller.current_user = nil }}
    With.share(:valid_article_params) { before { @params = valid_article_params } }
    With.share(:invalid_article_params) { before { @params = valid_article_params.except(:title) } }
    With.share(:invalid_article_params) { before { @params = valid_article_params.except(:body) } }

    Target.with_common :caching, :observers
    
    context = Target.describe 'POST to :create' do
      before { @before_block_called = true }
      action { post :create, @params }
      
      it "has called the before blocks" do
        assert @caching
        assert @observers
        assert @before_block_called
      end
      
      with :login_as_admin do
        it_assigns :article
    
        it "succeeds", :with => :valid_article_params do
          it_redirects_to { 'articles/1' }
    
          it "can nest assertions" do
            assert true
          end
        end
    
        it "fails", :with => :invalid_article_params do
          it_assigns_flash :error, /missing: (body|title)/
        end
      end
    
      with [:login_as_user, :no_login] do
        it_redirects_to { '/login' }
      end
    end
    
    methods = Target.instance_methods.grep(/^test/)
    #puts; puts Target.instance_methods.grep(/^test/).join(", \n  ")
    assert_equal 5, methods.count

    expected = [[['POST to :create', :caching, :observers, :login_as_admin, :valid_article_params],
                 ['POST to :create', :caching, :observers, :login_as_admin, :invalid_article_params],
                 ['POST to :create', :caching, :observers, :login_as_admin, :invalid_article_params],
                 ['POST to :create', :caching, :observers, :login_as_user],
                 ['POST to :create', :caching, :observers, :no_login]]]
    assert_equal expected, context_names([context])
    
  end
end