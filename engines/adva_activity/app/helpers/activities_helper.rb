module ActivitiesHelper
  def render_activities(activities, recent = false)
    if activities.present?
      html = activities.collect do |activity|
        render :partial => "admin/activities/#{activity.object_type.downcase}",
               :locals => { :activity => activity, :recent => recent }
      end
    else
      html = %(<li class="empty shade">#{I18n.t(:'adva.activity.none')}.</li>)
    end
    %(<ul class="activities">#{html}</ul>)
  end

  def activity_css_classes(activity)
    type = activity.object_attributes['type'] || activity.object_type
    "#{type}_#{activity.all_actions.last}".downcase
    # activity.all_actions.collect {|action| "#{type}-#{action}".downcase }.uniq * ' '
  end

  # def activity_datetime(activity, short = false)
  #   if activity.from and short
  #     from = activity.from.to_s(:time_only)
  #     to = activity.to.to_s(:time_only)
  #     "#{from} - #{to}"
  #   elsif activity.from and activity.from.to_date != activity.to.to_date
  #     from = activity.from.to_ordinalized_s(:plain)
  #     to = activity.to.to_ordinalized_s(:plain)
  #     "#{from} - #{to}"
  #   elsif activity.from
  #     from = activity.from.to_ordinalized_s(:plain)
  #     to = activity.to.to_ordinalized_s(:time_only)
  #     "#{from} - #{to}"
  #   else
  #     activity.created_at.send *(short ? [:to_s, :time_only] :  [:to_ordinalized_s, :plain])
  #   end
  # end

  def activity_datetime(activity, short = false)
    from, to = if activity.from && short
      [l(activity.from, :format => :time), l(activity.to, :format => :time)]
    elsif activity.from && activity.from.to_date != activity.to.to_date
      [l(activity.from, :format => :short), l(activity.to, :format => :short)]
    elsif activity.from
      [l(activity.from, :format => :short), l(activity.to, :format => :time)]
    end

    t(:'adva.activity.from_to', :from => from, :to => to)
  end

  def activity_object_edit_url(activity)
    type = activity.object_attributes['type'] || activity.object_type
    send "edit_admin_#{type}_path".downcase, activity.site_id, activity.section_id, activity.object_id
  end

  # FIXME not used anywhere?
  # def activity_commentable_edit_url(activity)
  #   type = activity.object_attributes['commentable_type']
  #   send "edit_admin_#{type}_path".downcase, activity.site_id, activity.section_id, activity.commentable_id
  # end
  
  # FIXME not used anywhere?
  # def link_to_activity_commentable(activity)
  #   link_to truncate(activity.commentable_title, 100), activity_commentable_url(activity)
  # end

  def link_to_activity_user(activity)
    if activity.author.registered?
      link_to activity.author_name, admin_site_user_path(activity.author)
    else
      activity.author_link(:include_email => true)
    end
  end
end