class Blog < Section  
  has_many :articles, :foreign_key => 'section_id', :dependent => :destroy do
    def permalinks
      # find_published(:all).map(&:permalink)
      published.map(&:permalink)
    end
  end

  if Rails.plugin?(:adva_safemode)
    class Jail < Section::Jail
      allow :archive_months, :article_counts_by_month, :articles_by_month
    end
  end

  class << self
    def content_type
      'Article'
    end
  end

  def archive_months
    article_counts_by_month.transpose.first
  end

  def article_counts_by_month
    articles_by_month.map{|month, articles| [month, articles.size]}
  end

  def articles_by_month
    @articles_by_month ||= articles.published.group_by(&:published_month)
  end
end
