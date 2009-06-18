module WillPaginate
  module ViewHelpers
    def will_paginate_with_i18n(collection, options = {})
      will_paginate_without_i18n(collection, options.reverse_merge(
        :previous_label => I18n.t(:'adva.pagination.previous', :default => '&#8249;'),
        :next_label => I18n.t(:'adva.pagination.next', :default => '&#8250;'))
      )
    end
    alias_method_chain :will_paginate, :i18n
  end
end