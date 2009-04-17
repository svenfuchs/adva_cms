$(document).ready(function() {
  $('td.actions a.clear').click(function(event) {
    event.preventDefault();
    $.ajax({
      url: this.href,
      type: 'delete',
      dataType: 'script'
    });
  });
})