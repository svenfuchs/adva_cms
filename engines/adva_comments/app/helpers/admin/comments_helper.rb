module Admin
  module CommentsHelper
    def comment_expiration_options
      I18n.with_options :scope => :'adva.comments.options.expiration' do |i18n|
        [ [i18n.t(:not_allowed),                           -1 ],
          [i18n.t(:never_expire),                           0 ],
          [i18n.t(:x_hours_after_publishing, :count => 24), 1 ],
          [i18n.t(:x_weeks_after_publishing, :count => 1),  7 ],
          [i18n.t(:x_months_after_publishing, :count => 1), 30],
          [i18n.t(:x_months_after_publishing, :count => 3), 90] ]
      end
    end

    def comments_filter_options
      options = I18n.t(:'adva.comments.filter.options')

      [[options[:all], 					'all'],
  		 [options[:state], 		    'state'],
  	   [options[:body],         'body'],
  	   [options[:author_name], 	'author_name'],
  	   [options[:author_email], 'author_email'],
  	   [options[:author_url],   'author_homepage']]
    end

    def comments_state_options
      options = I18n.t(:'adva.comments.state.options')

      [[options[:approved],   'approved'],
  		 [options[:unapproved], 'unapproved']]
    end
  end
end