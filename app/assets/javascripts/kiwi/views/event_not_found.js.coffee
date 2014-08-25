FK.App.module "Events.NotFound", (NotFound, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @view = new NotFoundView()
    @view.onClose = () =>
      @stop()
    App.mainRegion.show @view

  @addFinalizer () ->
    @view.close()
    @stopListening()

  class NotFoundView extends Marionette.ItemView
    template: FK.Template('not_found')
    className: 'event-page col-md-12'
