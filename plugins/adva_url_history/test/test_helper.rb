require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test/test_helper')

class TestController < ActionController::Base
  def show
    Article.find_by_permalink(params[:permalink]) || raise(ActiveRecord::RecordNotFound)
    render :text => 'show'
  end

  def non_get
    render :text => 'non_get'
  end

  def current_resource
    @article
  end

  def default_record_not_found
  end
end
