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
    tab = $(this.tabs[0]).is(":visible") ? this.tabs[0] : this.tabs[1];
    this.selectTab(tab);
  },
  selectTab: function(element) {
    this.tabs.removeClass("selected");
    $(element).addClass("selected");
    this.showPanel(element);
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
    $("#" + (element.id || $(element).attr("id")).replace("tab_", "")).show();
  }
});

var AssetWidget = {
  tinyTab: null,
  authenticityToken: null,
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
    return location.href.match(/\/[0-9]+\/edit#/);
  },
	collectionUrl: function(element) {
		return this.assetsUrl() + '/' + this.assetId(element) + '/contents';
	},
	memberUrl: function(element) {
		return this.collectionUrl(element) + '/' + this.memberId();
	},
  attachAsset: function(element, async) {
    if(!this.isAttached(element)) {
      $.ajax({
        url: this.collectionUrl(element),
				data: {
					content_id: this.memberId(),
					authenticity_token: this.authenticityToken
				},
        type: 'post',
        dataType: 'script',
        async: this.isAsync(async)
      });
		}
  },
  detachAsset: function(element, async) {
    if(this.isAttached(element)) {
      $.ajax({
        url: this.memberUrl(element),
        data: {
          _method: 'delete',
          authenticity_token: this.authenticityToken
        },
        type: 'post',
        dataType: 'script',
        async: this.isAsync(async)
      });
		}
  },
  isAsync: function(value) {
    return value === undefined;
  },
	isAttached: function(element) {
	  return $("#attached_asset_" + this.assetId(element)).exist();
	},
	updateSelected: function() {
		if(!$('#assets_widget').exist()) return;
		var selectedIds = this.selectedAssetIds();
		this.updateSelectedTab(selectedIds.length > 0);
		this.updateSelectedAssets(selectedIds);
	},
	updateSelectedTab: function(show) {
		show ? this.showSelectedTab() : this.hideSelectedTab();
		this.tinyTab.selectFirstTab();
	},
	showSelectedTab: function() {
		$('#tab_attached_assets').show();
		$("#attached_assets").addClass("asset_list");
	},
	hideSelectedTab: function() {
		$('#tab_attached_assets').hide();
		if(this.tinyTab.selectedTab() == $('#tab_attached_assets')) {
			this.tinyTab.unselectTab();
		}
		$('#attached_assets').hide().removeClass("asset_list");
	},
	updateSelectedAssets: function(ids) {
	  $.each(['latest', 'bucket'], function() {
	    $("." + this + "_asset").removeClass("selected");
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
		if(this.isEdit()) {
			$('#' + id + ' div').show();
		}
  },  
  hideAttachTools: function(id) {
		$('#' + id + ' div').hide();
  },
	search: function(query, async) {
    if(!query) return;
    $('#search_assets_spinner').show();
    $("#search_assets_result").html("");
    $.ajax({
      url: this.assetsUrl(),
      data: {
        query: escape(query),
        limit: 6,
        source: 'widget'
      },
      type: 'get',
      dataType: 'script',
      async: this.isAsync(async)
    });
	},
  upload: function(element) {
    if(!$("#asset_upload_frame").exist())
      $('body').append('<iframe id="asset_upload_frame" name="asset_upload_frame" style="display:none"></iframe>');

    var parent = $(element).parent();
		var form = $(document.createElement("form"))
		             .attr("method", "post")
		             .attr("action", this.assetsUrl())
		             .attr("enctype", "multipart/form-data")
		             .attr("target", "asset_upload_frame")
		             .attr("style", "display:none");
		form.append('<input type="hidden" name="authenticity_token" value="'+this.authenticityToken+'"></input>')
		    .append('<input type="hidden" name="respond_to_parent" value="1"></input>')
        .append($(element));
    $('body').append(form);

    form.submit();
    form.remove();
    parent.prepend('<input id="asset-uploaded-data" name="assets[][data]" type="file" />');
  }	
};

$(document).ready(function() {
  AssetWidget.tinyTab = new TinyTab("#assets_widget", "#panels");
  AssetWidget.authenticityToken = $("[name=authenticity_token]").val();
  AssetWidget.updateSelected();

  $("#assets_widget .attach_asset").live("click", function(event) { AssetWidget.attachAsset($(this)); });
  $("#assets_widget .detach_asset").live("click", function(event) { AssetWidget.detachAsset($(this)); });
  $("#assets_widget .asset").live("mouseover", function(event) { AssetWidget.showAttachTools($(this).attr("id")); });
  $("#assets_widget .asset").live("mouseout", function(event) { AssetWidget.hideAttachTools($(this).attr("id")); });

  $("#search_assets_button").click(function(event)   { AssetWidget.search($("#search_assets_query").val()); });
  $("#search_assets_query").keypress(function(event) { if(event.keyCode == 13) { AssetWidget.search($("#search_assets_query").val()); event.preventDefault(); } });
  $("#upload-assets-button").click(function(event)   { AssetWidget.upload($('#asset-uploaded-data')); });
});
