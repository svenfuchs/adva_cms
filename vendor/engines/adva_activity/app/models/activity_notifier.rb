class ActivityNotifier < ActionMailer::Base
  helper :content

  def new_content_notification(activity)
    subject "[#{activity.site.name} / #{activity.section.title}] New #{activity.object.class} posted"
    from "#{activity.site.name} <#{activity.site.email}>"
    body :activity => activity
  end
end