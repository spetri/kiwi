class FK.Views.Layout extends Backbone.Marionette.Layout
  template: FK.Template('layout')
  regions:
    navbar:    '#navbar'
    container: '#container'

  initialize: => 
    FK.App.vent.on('container:load',(e) =>
      @navbar.show(new FK.Views.Navbar(model: FK.CurrentUser))
    )

  onRender: ->
    @container.show(new FK.Views.Container())
