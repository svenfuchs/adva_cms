class Wikipage < Content  
  filters_attributes :sanitize => :body, :except => :body_html
  before_create :set_published
  
  # validates_presence_of :user_id TODO this should be in Content, right?
  
  def full_permalink
    { :id => permalink }
  end
  
  def after_initialize
    init_title_from_permalink if new_record? && title.blank?
  end
  
  def init_title_from_permalink
    self.title = permalink.to_s.gsub("-", " ").capitalize if permalink
  end
  
  def set_published
    self.published_at = Time.zone.now
  end
  
  def home?
    permalink == 'home' # TODO make this configurable per wiki? use the wiki section permalink by default?
  end
  
  #   def validate
  #     site = Site.find(:first)
  #     if site.akismet_key? && is_spam?(site)
  #       errors.add_to_base "Your comment was marked as spam, please contact the site admin if you feel this was a mistake."
  #     end
  #   end
  #   
  #   def is_spam?(site)
  #     v = Viking.connect("akismet", {:api_key => site.akismet_key, :blog => site.akismet_url})
  #     response = v.check_comment(:comment_content => body.to_s, :comment_author => user.login.to_s, :user_ip => ip.to_s, :user_agent => agent.to_s, :referrer => referrer.to_s)
  #     logger.info "Calling Akismet for page #{permalink} by #{user.login.to_s} using ip #{ip}:  #{response[:spam]}"
  #     return response[:spam]
  #   end
  #   
  #   def self.find_all_by_wiki_word(wiki_word)
  #     wikipages = self.find(:all)
  #     wikipages.select {|p| p.body =~ /#{wiki_word}/i}
  #   end  
end
