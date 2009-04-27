(function($) { $.fn.exist = function() { return this.length > 0; }; })(jQuery);

var TinyTab = $.klass({
  initialize: function(element, panels) {
    this.container = $(element);
    if(this.container.exist()) {
      var tabs = this.container.find(".tabs:first");
      // tabs.cleanWhitespace(); TODO find a jQuery equivalent method
      this.tabs = tabs.children();
      
      this.panels = this.container.find(".panel");
      this.showFirstPanel();
      this.selectFirstTab();
      var self = this;
      this.tabs.each(function() {
        $(this).bind("click", {self: self, element: this}, function(eventData) {
          var self = eventData.data.self;
          self.selectTab(eventData.data.element);
          eventData.stopPropagation();
        });
      });
    }
  },
  selectFirstTab: function() {
    this.selectTab(this.tabs[0]);
  },
  selectTab: function(element) {
    this.tabs.removeClass("selected");
    $(element).addClass("selected");
  },
  selectedTab: function() {
    return $($.grep(this.tabs, function(tab, i) {
      return $(tab).hasClass("selected");
    })[0]);
  },
  showFirstPanel: function() {
    this.showPanel(this.panels[0]);
  },
  showPanel: function(element) {
    this.panels.hide();
    $(element).show();
  }
});

var AssetWidget = {
  tinyTab: null,
	siteId: function() {
		return location.href.match(/sites\/([0-9]+)\//)[1];
	},
	assetId: function(element) {
		return element.attr('id').match(/_(\d+)$/)[1];
	},
	memberId: function() {
		return location.href.match(/\/([0-9]+)\/(edit)/)[1];
	},
	assetsUrl: function() {
		return '/admin/sites/' + this.siteId() + '/assets';
	},
  isEdit: function() {
    return location.href.match(/\/[0-9]+\/edit#?$/)
  },
	collectionUrl: function(element) {
		return this.assetsUrl() + '/' + this.assetId(element) + '/contents';
	},
	memberUrl: function(element) {
		return this.collectionUrl(element) + '/' + this.memberId();
	},
  attachAsset: function(element, authenticityToken) {
    if(!this.isAttached(element)) {
      $.post(this.collectionUrl(element), { 'content_id': this.memberId(), 'authenticity_token': authenticityToken });
		}
  },
  detachAsset: function(element, authenticityToken) {
    if(this.isAttached(element)) {
      $.post(this.memberUrl(element), { '_method': 'delete', 'authenticity_token': authenticityToken });
		}
  },
  exist: function(selector) {
    return $(selector).length > 0;
  },
	isAttached: function(element) {
	  return this.exist("#attached_asset_" + this.assetId(element));
	},
	updateSelected: function() {
		if(!this.exist('#assets_widget')) return;
		var selectedIds = this.selectedAssetIds();
		this.updateSelectedTab(selectedIds.length > 0);
		this.updateSelectedAssets(selectedIds);
	},
	updateSelectedTab: function(show) {
		show ? this.showSelectedTab() : this.hideSelectedTab();
		if(!this.tinyTab.selectedTab()){
			this.tinyTab.selectFirstTab();
		}
	},
	showSelectedTab: function() {
		$('#tab_attached_assets').show();
	},
	hideSelectedTab: function() {
		$('#tab_attached_assets').hide();
		if(this.tinyTab.selectedTab() == $('#tab_attached_assets')) {
			this.tinyTab.unselectTab();
		}
		$('#attached_assets').hide();
	},
	updateSelectedAssets: function(ids) {
	  $.each(['latest', 'bucket'], function() {
	    $("." + this + "_asset").each(function() { $(this).removeClass("selected"); });
	    var prefix = this;
	    $.each(ids, function() {
	      var asset = $("#" + prefix + "_asset_" + this);
	      if (asset.length > 0) { asset.addClass("selected"); }
	    });
	  });
	},
	selectedAssetIds: function() {
	  return $(".attached_asset").map(function(i, asset) {
	    return AssetWidget.assetId($(asset));
	  });
	},	
  showAttachTools: function(id) {
    if(this.isEdit())
      $.each(['attach', 'detach'], function() { $("#" + this + "_" + id).show(); });
  },  
  hideAttachTools: function(id) {
    $.each(['attach', 'detach'], function() { $("#" + this + "_" + id).hide(); });
  },
	search: function(query) {
    if(!query) return;
    $('#search_assets_spinner').show();
    $.get(this.assetsUrl(), { query: escape(query), limit: 6, source: 'widget' });
	},
  upload: function(element, authenticityToken) {
    if(!this.exist("#asset_upload_frame"))
      $('body').append('<iframe id="asset_upload_frame" name="asset_upload_frame" style="display:none"></iframe>');

		var form = $(document.createElement("form"))
		             .attr("method", "post")
		             .attr("enctype", "multipart/form-data")
		             .attr("target", "asset_upload_frame")
		             .attr("style", "display:none");
		form.append('<input type="hidden" name="authenticity_token" value="'+authenticityToken+'"></input>')
		    .append('<input type="hidden" name="respond_to_parent" value="1"></input>')
		    .append($(element).clone(true));
    $('body').append(form);
    form.submit();
    form.remove();
  }	
};

// Event.addBehavior({
//   '#assets_widget .attach_asset:click': function() { AssetWidget.attachAsset(this, $('content_form').authenticity_token.value); return false; },
//   '#assets_widget .detach_asset:click': function() { AssetWidget.detachAsset(this, $('content_form').authenticity_token.value); return false; },
//   '#assets_widget .asset:mouseover':     function() { AssetWidget.showAttachTools(this.getAttribute('id')); },
//   '#assets_widget .asset:mouseout':    function() { AssetWidget.hideAttachTools(this.getAttribute('id')); },
// 
//  '#search_assets_button:click':        function(event) { AssetWidget.search($F('search_assets_query')); },
//  '#search_assets_query:keypress':      function(event) { if(event.keyCode == Event.KEY_RETURN) { AssetWidget.search($F('search_assets_query')); Event.stop(event); } },
//  '#upload_assets_button:click':        function(event) { AssetWidget.upload($('asset_uploaded_data'), $('content_form').authenticity_token.value);}
// 
//   // '#assets_widget .asset img':          function() { new Draggable(this, { revert: true, ghosting: true }); },
//  //'#article_body':                      function() { Droppables.add(this, { onDrop: function(drag, drop, event) {} }); }
// });                                 
//
$(document).ready(function() {
  AssetWidget.tinyTab = new TinyTab("#assets_widget", "#panels");
  AssetWidget.updateSelected();
});
