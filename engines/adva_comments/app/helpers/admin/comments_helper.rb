module Admin
  module CommentsHelper
    def comment_expiration_options
      [['Are not allowed', -1],
       ['Never expire', 0],
       ['Expire 24 hours after publishing',     1],
       ['Expire 1 week after publishing',       7],
       ['Expire 1 month after publishing',      30],
       ['Expire 3 months after publishing',     90]]
    end

    def comments_filter_options
      options = I18n.t(:'adva.comments.filter.options')

      [[options[:all], 					'all'],
  		 [options[:state], 		    'state'],
  	   [options[:body],         'body'],
  	   [options[:author_name], 	'author_name'],
  	   [options[:author_email], 'author_email'],
  	   [options[:author_url],   'author_website']]
    end

    def comments_state_options
      options = I18n.t(:'adva.comments.state.options')

      [[options[:approved],   'approved'],
  		 [options[:unapproved], 'unapproved']]
    end
  end
end