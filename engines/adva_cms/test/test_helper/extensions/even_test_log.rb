# class Event
#   module TestLog
#     Event.observers << self
#     @@events = []
# 
#     class << self
#       def clear!
#         @@events = []
#       end
# 
#       def was_triggered?(type)
#         @@events.include? type
#       end
# 
#       def handle_event!(event)
#         @@events ||= []
#         @@events << event.type
#       end
#     end
#   end
# end
