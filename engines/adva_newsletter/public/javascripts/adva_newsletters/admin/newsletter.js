ExpandSaveOrCancel = $.klass({
  initialize: function(expanded_selector) {
    this.expanded_selector = expanded_selector;
  },
  onclick: function(event) {
    this.element.hide();
    $(this.expanded_selector).show();
		event.preventDefault();
  }
});

jQuery(function($) {
  $('#send_later').attach(ExpandSaveOrCancel, '#send_later_expanded');
});
