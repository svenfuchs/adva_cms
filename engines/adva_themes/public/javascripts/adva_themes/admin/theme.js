(function($){
  $.fn.identify = function(count) {
    return this.each(function() {
      $(this).find(":input").each(function() {
        $(this).attr("id",   $(this).attr("id").replace("0", count))
               .attr("name", $(this).attr("name").replace("0", count));
      });
    });
 };
})(jQuery);

var ThemeFileUpload = $.klass({
  initialize: function() {
    $("#theme_add_file").bind("click", this.addInput);
  },
  addInput: function() {
    var list = $("#files div"), copyFrom = list.find("p:first");
    var newNode = copyFrom.clone(true), files = list.children("p");
    newNode.find("input").each(function(){ $(this).val("") });
    var close = newNode.find(".theme_remove_file:first").show();
    newNode.identify(files.length);
    close.click(function(){
      $(this).parent("p").remove();
    });
    newNode.appendTo(list);
  }
});

$().ready(function(){
  new ThemeFileUpload();
});