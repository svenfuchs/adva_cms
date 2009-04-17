var Filter = {
  add: function() {
    var set = $(this).closest('.set');
    set.clone().insertBefore(set);
    $('.filter_remove', set).removeClass('first');
  },
  remove: function() {
    $(this).closest('.set').remove();
  },
  select: function() {
    var set = $(this).closest('.set');
    var name = this.options[this.selectedIndex].value;

    $('.filter', set).removeClass('selected');
    $($('.filter_' + name, set)[0]).addClass('selected');
  }
}

$(document).ready(function() {
  $('.selected_filter').live('click', Filter.select);
  $('.filter_add').live('click', Filter.add);
  $('.filter_remove').live('click', Filter.remove);
});