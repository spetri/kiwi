FK.App.module "Events.NotFound", (NotFound, App, Backbone, Marionette, $, _) ->
  
  @startWithParent = false

  @addInitializer () ->
    console.log('start')
    @view = new NotFoundView()
    @view.onClose = () =>
      @stop()
      $("body").removeClass('not-found')

    @.on 'start', () =>
      App.mainRegion.show @view
      $("body").addClass('not-found')

  @addFinalizer () ->
    @view.close()
    @stopListening()

  class NotFoundView extends Marionette.ItemView
    template: FK.Template('not_found')
    className: 'container'
