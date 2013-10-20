class FK.Views.Container extends Backbone.Marionette.Layout
  template: FK.Template('container')
  className: "row-fluid"

  initialize: =>
    FK.App.vent.on('container:all', @all)

  #TODO: Move these into their own modules
  onRender: -> 
    @all()
    FK.App.sidebarRegion.show(new FK.Views.Sidebar()) 

  all: (e) =>
    FK.App.mainRegion.show(new FK.Views.Events())
