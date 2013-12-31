FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventCollapsed extends Backbone.Marionette.ItemView
    template: FK.Template('event_collapsed')
    className: 'event'
    tagName: 'div'
    events:
      'click .delete': 'deleteClicked'
      'click .event-name': 'triggerEventOpen'

    templateHelpers: =>
     time: =>
      @model.get('time')

     all_day: =>
      return true if @model.get('is_all_day') is '1' or @model.get('is_all_day') is true
      return false

    deleteClicked: (e) ->
      e.preventDefault()
      @model.destroy()

    triggerEventOpen: (e) ->
      e.preventDefault()
      EventList.trigger 'clicked:open', @model
