class FK.Views.Layout extends Backbone.Marionette.Layout
  template: FK.Template('layout')
  regions:
    navbar:    '#navbar'
    container: '#container'

  initialize: =>

  onRender: ->
    @container.show(new FK.Views.Container())
