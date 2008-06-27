class Blog < Section  
  permissions :article  => { :user => [:create, :update, :destroy], :anonymous => :show },
              :comment  => { :user => :create, :author => [:update, :destroy] }

  def archive_months
    article_counts_by_month.transpose.first
  end

  def article_counts_by_month
    articles_by_month.map{|month, articles| [month, articles.size]}
  end

  def articles_by_month
    @articles_by_month ||= articles.find_published(:all).group_by(&:published_month)
  end
end