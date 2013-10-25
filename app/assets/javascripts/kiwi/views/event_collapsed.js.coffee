FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class FK.Views.EventCollapsed extends Backbone.Marionette.ItemView
    template: FK.Template('event_collapsed')
    tagName: 'li'
    events:
      'click .delete': 'deleteClicked'
      'click .event-name': 'triggerEventOpen'

    templateHelpers: =>
     time: =>
      @model.get('time')

    deleteClicked: (e) ->
      e.preventDefault()
      @model.destroy()

    triggerEventOpen: (e) ->
      e.preventDefault()
      EventList.trigger 'clicked:open', @model
      
