module Activities
  class SectionObserver < Activities::Logger
    observe :section

    def after_destroy(record)
      Activity.destroy_all(:section_id => record.id)
    end
  end
end
