FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.SingleSubkastView extends Marionette.ItemView
    template: FK.Template('single_subkast')

    triggers:
      'click a': 'clicked'
