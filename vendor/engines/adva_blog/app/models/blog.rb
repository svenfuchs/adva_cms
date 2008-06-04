class Blog < Section  
  self.default_required_roles = { :manage_articles => :admin, 
                                  :manage_categories => :admin }
                                  
  def archive_months
    articles.find_published(:all).group_by(&:published_month)
  end
  
  protected  
    def set_comment_age
      self.comment_age ||= 0
    end
end