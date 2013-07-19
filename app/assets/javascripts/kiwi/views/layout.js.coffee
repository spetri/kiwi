class FK.Views.Layout extends Backbone.Marionette.Layout
  template: FK.Template('layout')
  regions:
    navbar:    '#navbar'
    container: '#container'

  onRender: ->
    @navbar.show(new FK.Views.Navbar())
    @container.show(new FK.Views.Container())
