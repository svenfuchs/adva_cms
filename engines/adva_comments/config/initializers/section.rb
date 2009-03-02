class SectionFormBuilder < ExtensibleFormBuilder
  before(:section, :submit_buttons) do |f|
    unless @section.type == 'Forum'
      render :partial => 'admin/sections/comments_settings', :locals => { :f => f }
    end
  end
end

ActionController::Dispatcher.to_prepare do
  Section.class_eval do
    before_validation :set_comment_age
    has_many_comments :foreign_key => :section_id, :as => :section

    def accept_comments?
      comment_age.to_i > -1
    end

    protected

      def set_comment_age
        self.comment_age ||= -1
      end
  end
end
