class Blog < Section  
  permissions :article  => { :user => [:create, :update, :delete] },
              :comment  => { :user => :create, :author => [:update, :delete] }

  def archive_months
    articles.find_published(:all).group_by(&:published_month)
  end
end