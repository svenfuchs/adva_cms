// TODO inject TestUtils methods in window
var TestUtils = {
  defaultTags: "adva tags",
  uploadSummary: "You have a uploaded a total of <strong>0 assets</strong>, using <strong>0 Bytes</strong>.",

  files: function() {
    return $("#files div").children("p");
  },
  lastFileRow: function(){
    return $("#files div").children("p:last");
  },
  simulateClick: function() {
    jQuery("#asset_add_file").click();
  },
  copyFrom: function() {
    return $("#files div").find("p:first");
  },
  tagAll: function() {
    jQuery("#tagall_files").click();
  },
  fillCopyFromWithTags: function(element, tags) {
    element = element || this.copyFrom();
    tags = tags || this.defaultTags;
    element.find("input:last").val(tags);
  },
  emptyCopyFromTags: function() {
    this.fillCopyFromWithTags("");
  },
  asset: function() {
    return $(".assets_row div:first");
  },
  assetTools: function() {
    return $(".asset_tools:first");
  },
  simulateMouseOver: function() {
    this.asset().mouseover();
  },
  simulateMouseOut: function() {
    this.asset().mouseout();
  }
}

$.extend(Assets, {
  // Can't run tests with window.confirm
  deleteAsset: function(element, async) {
    this.ajaxRequest(element, "delete", async);
  }
});

module("ADD INPUT");
test("should add input row on click", function() {
  equals(TestUtils.files().size(), 1);
  TestUtils.simulateClick();
  equals(TestUtils.files().size(), 2, "it should have two input rows after click");
});

test("should empty inputs when new created", function() {
  TestUtils.fillCopyFromWithTags();
  TestUtils.simulateClick();
  TestUtils.lastFileRow().find("input").each(function(){
    equals($(this).val(), "");
  });
});

test("should create input with unique DOM ids", function() {
  TestUtils.simulateClick();
  inputs = $(TestUtils.files()[1]).find(":input");
  inputs.each(function() {
    ok(!$(this).attr("id").match("0"), "Should increment the id count");
    ok(!$(this).attr("name").match("0"), "Should increment the name count");
  });
});

test("should hide 'remove_file' link for first row", function(){
  ok(!TestUtils.copyFrom().find(".remove_file:first").is(":visible"), "'remove_file' shouldn't be visible");
});

test("should show 'remove_file' link for new rows", function(){
  TestUtils.simulateClick();
  ok(TestUtils.lastFileRow().find(".remove_file:first").is(":visible"), "'remove_file' should be visible");
});

test("should show 'tagall_files' link for first row", function(){
  ok(TestUtils.copyFrom().find(".tagall_files:first").is(":visible"), "'tagall_files' should be visible");
});

test("should remove 'tagall_files' link for new rows", function(){
  TestUtils.simulateClick();
  // TODO replace with proper QUnit existence assertion
  equals(TestUtils.lastFileRow().find(".tagall_files:first").size(), 0, "'tagall_files' should be removed");
});

test("should remove input row when click on 'remove_file' link", function(){
  TestUtils.simulateClick();
  var filesCount = TestUtils.files().size();
  TestUtils.lastFileRow().find(".remove_file:first").click();
  equals(TestUtils.files().size(), filesCount - 1, "should remove row when click on 'remove_file' link");
});

module("APPLY TAGS TO ALL");
test("should apply tags to all when click on 'tagall_files'", function(){
  TestUtils.simulateClick();
  TestUtils.tagAll();
  TestUtils.files().find("input:last").each(function(){
    equals($(this).val(), TestUtils.defaultTags);
  });
});

test("should add tags when click on 'tagall_files' and input has existing tags", function(){
  TestUtils.simulateClick();
  TestUtils.fillCopyFromWithTags(TestUtils.lastFileRow(), "rails");
  TestUtils.tagAll();
  equals(TestUtils.lastFileRow().find("input:last").val(), "rails " + TestUtils.defaultTags);
});

module("BUCKET");
test("should add to bucket", function() {
  Assets.addToBucket($(".add_asset"), false);
  ok($('#bucket_assets').children().size() > 0, "#bucket_assets should be empty.");
  equals($("#flash_notice").html(), "rails.png assigned to this bucket.");
});

test("should clear the bucket", function() {
  Assets.addToBucket($("#clear_bucket"), false);
  equals($('#bucket_assets').children().size(), 0, "#bucket_assets shouldn't be empty.");
  equals($("#flash_notice").html(), "Asset bucket has been cleared.");
});

module("ASSET TOOLS");
test("should show assets tools when mouse is over an asset preview", function(){
  ok(!TestUtils.assetTools().is(":visible"), "asset tools should be hidden by default");
  TestUtils.simulateMouseOver();
  ok(TestUtils.assetTools().is(":visible"), "asset tools should be visible when the mouse is over the relative asset preview");
});

test("should hide assets tools when mouse is away from an asset preview", function(){
  TestUtils.simulateMouseOver();
  ok(TestUtils.assetTools().is(":visible"), "asset tools should be visible when the mouse is over the relative asset preview");
  TestUtils.simulateMouseOut();
  ok(!TestUtils.assetTools().is(":visible"), "asset tools should be hidden when the mouse is away from the asset preview");
});

test("should delete the asset", function() {
  Assets.deleteAsset($(".delete_asset"), false);
  ok($('#asset_1').length == 0, "#asset_1 shouldn't exist.");
  equals($("#flash_notice").html(), "'rails.png' was deleted.");
  equals($("#upload_summary").html(), TestUtils.uploadSummary);
});
