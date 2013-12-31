class FK.Views.EventBlock extends Backbone.Marionette.Layout
  template: FK.Template('event_block')
  templateHelpers: () =>
    return {
      isToday: () => @model.isToday()
    }
  regions:
    event_collection: 'div.event_collection'
  onRender: ->
    @event_collection.show(new FK.Views.EventCollection(collection: @model.get('events')))
