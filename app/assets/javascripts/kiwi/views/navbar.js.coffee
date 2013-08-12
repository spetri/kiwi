class FK.Views.Navbar extends Backbone.Marionette.ItemView
  className: "navbar-inner"
  template: FK.Template('navbar')
  events:
    'click .new-event': 'newEventClicked'
    'click .all-events': 'allEventsClicked'

  newEventClicked: (e) =>
    e.preventDefault()
    FK.App.trigger('new-event')

  allEventsClicked: (e) =>
    e.preventDefault()
    FK.App.trigger('all-events')
