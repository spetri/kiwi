FK.App.module "Events.NotFound", (NotFound, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @view = new NotFoundView()
    @view.onClose = () =>
      @stop()
      $("body").removeClass('not-found')
    App.mainRegion.show @view
    $("body").addClass('not-found')

  @addFinalizer () ->
    @view.close()
    @stopListening()

  class NotFoundView extends Marionette.ItemView
    template: FK.Template('not_found')
    className: 'container'
