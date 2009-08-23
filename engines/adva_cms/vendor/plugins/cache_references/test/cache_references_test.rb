require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class CacheReferencesTest < Test::Unit::TestCase
  def setup
    @article = Article.new
    @comment = Comment.new

    @controller = ArticlesController.new
    @controller.stubs(:save_cache_references)
    @controller.instance_variable_set(:@article, @article)
    @controller.instance_variable_set(:@comments, [@comment])
  end

  def tracker
    @controller.instance_variable_get(:@method_call_tracker)
  end

  def test_access_to_an_attribute_on_an_observed_object_records_the_reference
    @controller.send :render
    @article.title
    assert tracker.references.include?([@article, nil])
  end

  def test_access_to_a_registered_method_on_an_observed_object_records_the_reference
    @controller.send :render
    @article.section
    assert tracker.references.include?([@article, :section])
  end

  def test_access_to_an_attribute_on_an_observed_array_of_objects_records_the_reference
    @controller.send :render
    @comment.body
    assert tracker.references.include?([@comment, nil])
  end

  def test_access_to_a_registered_method_on_an_observed_array_of_objects_records_the_reference
    @controller.send :render
    @comment.section
    assert tracker.references.include?([@comment, :section])
  end

  def test_does_not_setup_method_call_tracking_if_skip_caching_is_passed_as_option
    @controller.send :render, :skip_caching => true
    @article.title
    assert_equal nil, tracker
  end

  def test_does_not_setup_method_call_tracking_if_skip_caching_is_called_on_controller
    @controller.skip_caching!
    @controller.send :render
    @article.title
    assert_equal nil, tracker
  end
end