class FK.Views.EventCollection extends Backbone.Marionette.CompositeView
  itemView: FK.Views.EventCollapsed
  template: FK.Template('event_collection')
  itemViewContainer: 'ul'
