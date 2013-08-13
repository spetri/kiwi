class FK.Views.EventCollapsed extends Backbone.Marionette.ItemView
  template: FK.Template('event_collapsed')
  tagName: 'li'
  events:
    'click .delete': 'deleteClicked'

  deleteClicked: (e) ->
    e.preventDefault()
    @model.destroy()
