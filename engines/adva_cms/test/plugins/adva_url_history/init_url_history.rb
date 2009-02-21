# Gotta include this file if we want to test url_history in context of adva-cms.
# There seems to be no easy way to dynamically install and uninstall around filters
# in ActionController. Thus we can only test adva-cms with or without url_history
# initialized.

Content.class_eval do
  def update_url_history_params(params)
    if params.has_key?(:year)
      params.merge self.full_permalink
    elsif params.has_key?(:permalink)
      params.merge :permalink => self.permalink
    else
      params
    end
  end
end

ApplicationController.tracks_url_history
