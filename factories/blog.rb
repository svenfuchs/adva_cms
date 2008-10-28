Factory.define :blog do |b|
  b.title "adva-cms Blog"
  b.site { |b| b.association(:site) }
end

Factory.define :unpublished_blog_article, :class => Article do |a|
  a.title   "adva-cms kicks ass!"
  a.body    "Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!"
  a.excerpt "In this article you will find proof that adva-cms really kicks ass."
  a.author { |a| a.association(:user) }
  a.site_id { |a| a.association(:site_with_blog).id }
  a.section_id { |a| a.association(:blog).id }
end

Factory.define :published_blog_article, :class => Article do |a|
  a.title   "adva-cms kicks ass!"
  a.body    "Recent studies have proven that adva-cms really kicks ass - it's not just what the developers tell you!"
  a.excerpt "In this article you will find proof that adva-cms really kicks ass."
  a.author { |a| a.association(:user) }
  a.site_id { |a| a.association(:site_with_blog).id }
  a.section_id { |a| a.association(:blog).id }
  a.published_at Time.local(2008, 10, 16, 22, 0, 0)
end