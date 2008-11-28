class Admin::NewslettersController < Admin::BaseController
  def index
  end
  
  def new
    @newsletter = Newsletter.new
    @issue = Issue.new
  end
end
