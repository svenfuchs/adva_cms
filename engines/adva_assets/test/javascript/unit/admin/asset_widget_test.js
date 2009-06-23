TestUtils = {
  element: $("#asset_1"),
  tinyTab: function() {
    return new TinyTab('#assets_widget', '#panels');
  },
  reset: function() {
    $("#tab_attached_assets").hide();
    $("#flash_notice").html("").hide();
    $("#attached_assets").text("Your bucket is empty.");
  },
  attachAsset: function() {
    this.reset();
    $("#attached_assets").html('<ul id="attached_assets" class="panel asset_list">' +
      '<li id="attached_asset_4" class="asset attached_asset selected">' +
        '<a href="/assets/flower.jpg"><img alt="flower" src="/assets/flower.tiny.jpg?1240920626"></a>' +
        '<div style="display:none">' +
          '<a href="#"><img alt="Add" class="attach_asset" height="16" id="attach_attached_asset_4" src="/images/adva_cms/icons/add.png?1239718032" width="16" name="attach_attached_asset_4"></a>' +
          '<a href="#"><img alt="Delete" class="detach_asset" height="16" id="detach_attached_asset_4" src="/images/adva_cms/icons/delete.png?1239718032" width="16" name="detach_attached_asset_4"></a>' +
        '</div>' +
      '</li>' +
    '</ul>');
  },
  attachSearchResult: function() {
    $("#search_assets_result").html('<li><a href="/adva_assets/assets/rails.png"><img alt="rails logo" src="/adva_assets/assets/rails.thumb.png" style="thumb"></a></li>');
  }
}

module("jQuery exist");
test("should verify existence of elements", function() {
  ok($("#assets_widget").exist(), "should verify the existence of #assets_widget");
  ok(!$("#unexistent").exist(),   "shouldn't verify the existence of #unexistent");
});

module("ASSET WIDGET");

test("should return site id", function() {
  ok(false, "flunked: cannot mock location.href for now.");
});

test("should return asset id", function() {
  equals(AssetWidget.assetId(TestUtils.element), "1");
});

test("should return member id", function() {
  ok(false, "flunked: cannot mock location.href for now.");
});

test("should return assets url", function() {
  $.extend(AssetWidget, { siteId: function() {return "1";} });
  equals(AssetWidget.assetsUrl(), '/admin/sites/1/assets');
});

test("should guess if it is an edit", function() {
  ok(false, "flunked: cannot mock location.href for now.");
});

test("should return collection url", function() {
  equals(AssetWidget.collectionUrl(TestUtils.element), '/admin/sites/1/assets/1/contents');
});

test("should return member url", function() {
  $.extend(AssetWidget, { memberId: function() {return "1";} });
  equals(AssetWidget.memberUrl(TestUtils.element), '/admin/sites/1/assets/1/contents/1');
});

test("should attach asset", function() {
  $.extend(AssetWidget, { collectionUrl: function(element) { return "/adva_assets/controllers/attach"; } });
  AssetWidget.attachAsset(TestUtils.element, false);
  ok($("#flash_notice").is(":visible"), "should be visible");
  equals($("#flash_notice").html(), "pony.jpg assigned to this article.");
  ok($("#tab_attached_assets").hasClass("selected"), "should be selected");
  ok($("#tab_attached_assets").is(":visible"), "should be visible");
  // ok($("#attached_assets").text() == "", "should delete 'Your bucket is empty string.'");
  ok($("#attached_asset_23").exist(), "#attached_asset_23 should exist");
  $("#attached_asset_23").find(".detach_asset:first").click();
  // TODO the detach operation is performed in an async flavor,
  // the test is more fastere than the AJAX call, this cause a failure,
  // even if the element is correctly removed.
  // ok(!$("#attached_asset_23").exist(), "#attached_asset_23 shouldn't exist, since it was bound to a 'live' event");
});

test("should detach asset", function() {
  $.extend(AssetWidget, { collectionUrl: function(element) { return "/adva_assets/controllers/detach";} });
  TestUtils.attachAsset();
  AssetWidget.detachAsset($("#asset_2"), false);
  ok($("#flash_notice").is(":visible"), "#flash_notice should be visible");
  equals($("#flash_notice").html(), "flower.jpg unassigned from this article.");
  ok(!$("#attached_asset_4").exist(), "#attached_asset_4 shouldn't exist");
});

test("should verify if it is attached", function() {
  ok(!AssetWidget.isAttached(TestUtils.element), "It should not be attached (no attached_asset_1 element).");
  ok(AssetWidget.isAttached($("#asset_2")), "It should be attached (attached_asset_4 element).");
});

test("should update selected", function() {
  AssetWidget.updateSelected();
  ok($("#tab_attached_assets").is(":visible"), "should be visible");
  ok(!$(".latest_asset").hasClass("selected"),  "should not be selected");
  ok(!$(".bucket_asset").hasClass("selected"),  "should not be selected");
  ok($("#latest_asset_2").hasClass("selected"), "should be selected");
  ok($("#bucket_asset_2").hasClass("selected"), "should be selected");
});

test("should update selected tab", function() {
  AssetWidget.updateSelectedTab(false);
  ok(!$("#tab_attached_assets").is(":visible"), "should not be visible");
  ok(!$("#attached_assets").is(":visible"),     "should not be visible");

  AssetWidget.updateSelectedTab(true);
  ok($("#tab_attached_assets").is(":visible"), "should be visible");
});

test("should show selected tab", function() {
  TestUtils.reset();
  AssetWidget.showSelectedTab();
  ok($("#tab_attached_assets").is(":visible"), "should be visible");
  ok($("#attached_assets").hasClass("asset_list"), "#attached_assets should have 'asset_list' class");
});

test("should hide selected tab", function() {
  AssetWidget.hideSelectedTab();
  ok(!$("#tab_attached_assets").is(":visible"), "should not be visible");
  ok(!$("#attached_assets").is(":visible"),     "should not be visible");
  ok(!$("#attached_assets").hasClass("asset_list"), "#attached_assets shouldn't have 'asset_list' class");
});

test("should update selected assets", function() {
  AssetWidget.updateSelectedAssets([1]);
  ok(!$(".latest_asset").hasClass("selected"),  "should not be selected");
  ok(!$(".bucket_asset").hasClass("selected"),  "should not be selected");
  ok($("#latest_asset_1").hasClass("selected"), "should be selected");
  ok($("#bucket_asset_1").hasClass("selected"), "should be selected");
});

test("should return selected assets ids", function() {
  // same(AssetWidget.selectedAssetIds(), ["2"]);
  equals(AssetWidget.selectedAssetIds()[0], ["2"][0]);
});

test("should show attach tools", function() {
  $.extend(AssetWidget, {isEdit: function() { return true; }});
  AssetWidget.showAttachTools("latest_asset_1");
  ok($("#attach_latest_asset_1").is(":visible"), "should be visible");
  ok($("#detach_latest_asset_1").is(":visible"), "should be visible");
});

test("should hide attach tools", function() {
  AssetWidget.hideAttachTools(1);
  ok(!$("#attach_1").is(":visible"), "should not be visible");
  ok(!$("#detach_1").is(":visible"), "should not be visible");
});

test("should not perform search if query is missing", function() {
  ok(!$("#search_assets_spinner").is(":visible"), "spinner should not be visible");
  AssetWidget.search();
  ok(!$("#search_assets_spinner").is(":visible"), "spinner should not be visible");
});

test("should search", function() {
  $.extend(AssetWidget, { assetsUrl: function() { return "/adva_assets/controllers/search"; } });
  ok(!$("#search_assets_spinner").is(":visible"), "spinner should not be visible");
  AssetWidget.search("rails", false);
  ok($("#search_assets_spinner").is(":visible"), "spinner should be visible");
  ok($("#search_assets_result li a").exist(), "#search_assets_result should not be empty");
});

test("should remove previous search results when performs a new one", function(){
  TestUtils.attachSearchResult();
  AssetWidget.search("rails"); // async req, this time is OK, because the following assertion is much faster than XHR
  ok(!$("#search_assets_result li a").exist(), "#search_assets_result should be empty");
});

test("should upload", function() {
  $.extend(AssetWidget, { assetsUrl: function() { return "/adva_assets/controllers/upload";} });
  AssetWidget.upload(TestUtils.element, "authenticityToken");
  ok($("#asset_upload_frame").exist(), "should create an iframe");
  ok($("#asset-uploaded-data").exist(), "should append a brand new input text");
});

module("TINY TAB");
test("should initialize", function() {
  tinyTab = TestUtils.tinyTab();
  // equals(tinyTab.tabs, $(".tabs").children());
  // equals(tinyTab.panels, $(".panel"));
  equals(tinyTab.tabs.length, 5);
  equals(tinyTab.panels.length, 1);
  // ok($(tinyTab.panels[0]).is(":visible"), "first panel should be visible");
  ok($(tinyTab.tabs[1]).hasClass("selected"), "first available panel should be selected")
});

test("should observe tabs clicks", function() {
  tinyTab = TestUtils.tinyTab();
  tab = $(tinyTab.tabs[3]);
  tab.click();
  ok(tab.hasClass("selected"), "should have 'selected' class");
});

test("should select tab", function() {
  tinyTab = TestUtils.tinyTab();
  tab = tinyTab.tabs[1];
  tinyTab.selectTab(tab);
  ok($(tab).hasClass("selected"), "should have 'selected' class");
});

test("should select first tab", function() {
  tinyTab = TestUtils.tinyTab();
  tinyTab.selectFirstTab();
  ok($(tinyTab.tabs[1]).hasClass("selected"), "should have 'selected' class");
});

test("should return selected tab", function() {
  tinyTab = TestUtils.tinyTab();
  tab = $(tinyTab.tabs[2]);
  $(".selected").removeClass("selected");
  tinyTab.selectTab(tab);
  equals(tinyTab.selectedTab().attr("id"), tab.attr("id"));
});
