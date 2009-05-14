var CachedPage = {
  clearAll: function(event) {
    event.preventDefault();
    $.ajax({
      url: this.href,
      type: 'delete',
      dataType: 'script'
    });
  }
}

$(document).ready(function() {
  $('td.actions a.clear').click(CachedPage.clearAll);
});