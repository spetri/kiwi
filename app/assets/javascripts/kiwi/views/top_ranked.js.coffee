FK.App.module "Events.EventSidebar", (EventSidebar, App, Backbone, Marionette, $, _) ->

  class FK.Views.TopRanked extends Backbone.Marionette.ItemView
    template: FK.Template('top_ranked')
    className: 'top-ranked'
    onBeforeRender: ->
      #TODO: fix the slime
      @model = @collection
