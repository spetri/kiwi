class FK.Views.Container extends Backbone.Marionette.Layout
  template: FK.Template('container')
  className: "row-fluid"

  #TODO: Move these into their own modules
  onRender: ->
    FK.App.sidebarRegion.show(new FK.Views.Sidebar())
