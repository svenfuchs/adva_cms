# require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
#
# def expected_asset_expansions
#   {
#     :default => {
#       :javascripts => {
#         :adva_cms      => %w( adva_cms/prototype.js adva_cms/effects.js adva_cms/lowpro.js
#                               adva_cms/flash.js adva_cms/cookie.js adva_cms/json.js
#                               adva_cms/parseuri.js adva_cms/roles.js adva_cms/application.js ),
#         :adva_calendar => %w( adva_calendar/calendar.js )
#       },
#       :stylesheets => {
#         :adva_cms      => %w( adva_cms/default.css adva_cms/common.css adva_cms/forms.css
#                               adva_cms/comments.css adva_cms/forum.css )
#       }
#     },
#     :login => {
#       :javascripts => {
#         :adva_cms      => %w( adva_cms/prototype.js adva_cms/effects.js adva_cms/lowpro.js
#                               adva_cms/flash.js adva_cms/cookie.js adva_cms/json.js
#                               adva_cms/dragdrop.js adva_cms/sortable_tree/sortable_tree.js
#                               adva_cms/admin/admin.js adva_cms/admin/article.js
#                               adva_cms/admin/smart_form.js adva_cms/admin/sortable_tree.js
#                               adva_cms/admin/sortable_list.js adva_cms/admin/spotlight.js
#                               adva_cms/admin/asset.js adva_cms/admin/asset_widget.js
#                               adva_cms/admin/comment.js adva_cms/admin/wikipage.js ),
#         :adva_calendar => %w( adva_calendar/admin/calendar.js )
#       },
#       :stylesheets => {
#         :adva_cms      => %w( adva_cms/admin/form.css adva_cms/admin/lists.css
#                               adva_cms/admin/sortable_tree.css adva_cms/admin/themes.css
#                               adva_cms/admin/users.css adva_cms/admin/widgets.css
#                               adva_cms/admin/activities.css adva_cms/admin/assets.css
#                               adva_cms/admin/layout/base.css adva_cms/admin/layout/login.css )
#       }
#     },
#     :simple => {
#       :javascripts => {
#         :adva_cms      => %w( adva_cms/admin/base.css adva_cms/admin/form.css
#                               adva_cms/admin/layout/base.css adva_cms/admin/layout/simple.css ),
#         :adva_calendar => %w( adva_calendar/calendar.js )
#       },
#       :stylesheets => {
#         :adva_cms      => %w( adva_cms/prototype.js adva_cms/effects.js adva_cms/lowpro.js
#                               adva_cms/flash.js adva_cms/cookie.js adva_cms/json.js
#                               adva_cms/dragdrop.js adva_cms/sortable_tree/sortable_tree.js )
#       }
#     },
#     :admin => {
#       :javascripts => {
#         :adva_cms      => %w( adva_cms/prototype.js adva_cms/effects.js adva_cms/lowpro.js
#                               adva_cms/flash.js adva_cms/cookie.js adva_cms/json.js
#                               adva_cms/dragdrop.js adva_cms/sortable_tree/sortable_tree.js
#                               adva_cms/admin/admin.js adva_cms/admin/article.js
#                               adva_cms/admin/smart_form.js adva_cms/admin/sortable_tree.js
#                               adva_cms/admin/sortable_list.js adva_cms/admin/spotlight.js
#                               adva_cms/admin/asset.js adva_cms/admin/asset_widget.js
#                               adva_cms/admin/comment.js adva_cms/admin/wikipage.js ),
#         :adva_calendar => %w( adva_calendar/admin/calendar.js )
#       },
#       :stylesheets => {
#         :adva_cms      => %w( adva_cms/admin/form.css adva_cms/admin/lists.css
#                               adva_cms/admin/sortable_tree.css adva_cms/admin/themes.css
#                               adva_cms/admin/users.css adva_cms/admin/widgets.css
#                               adva_cms/admin/activities.css adva_cms/admin/assets.css )
#       }
#     }
#   }
# end
#
# class AssetTagExpansionsTest < ActionController::TestCase
#   tests ArticlesController
#   with_common :a_page
#
#   describe "GET to frontend page page" do
#     action { get :index, params_from("/a-page") }
#     it "includes the appropriate asset tags" do
#
#     end
#   end
# end
#
