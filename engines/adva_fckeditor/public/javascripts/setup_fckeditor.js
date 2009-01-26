// hash to store all editor references
var editors = new Hash();

Event.onReady(function() {
  // by default, apply FCKeditor to all textareas
  $$('textarea').each(function(t) {
    // some calculations
    height = t.getDimensions()['height'];
    if(height == 0) height = 200; // default height = 200px

    // initialize FCKeditor
    var oFCKeditor = new FCKeditor(t.id);
    oFCKeditor.BasePath = '/javascripts/adva_fckeditor/fckeditor/';
    oFCKeditor.Config['CustomConfigurationsPath'] = '/javascripts/adva_fckeditor/config.js';
    oFCKeditor.ToolbarSet = 'adva-cms';
    oFCKeditor.Height = height;
    oFCKeditor.ReplaceTextarea();
    // store all references
    editors[t.id] = oFCKeditor;
  });
});