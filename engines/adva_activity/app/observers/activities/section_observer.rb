module Activities
  class SectionObserver < ActiveRecord::Observer
    observe :section

    def after_destroy(record)
      Activity.destroy_all(:section_id => record.id)
    end
  end
end
