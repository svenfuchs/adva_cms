$(document).ready(function() {
  $('.selected_filter').live('click', function() {
    var set = $(this).closest('.set');
    var name = this.options[this.selectedIndex].value;

    $('.filter', set).removeClass('selected');
    $($('.filter_' + name, set)[0]).addClass('selected');
  });

  $('.filter_add').live('click', function() {
    var set = $(this).closest('.set');
    set.clone().insertBefore(set);
    $('.filter_remove', set).removeClass('first');
  });

  $('.filter_remove').live('click', function() {
    $(this).closest('.set').remove();
  });
});