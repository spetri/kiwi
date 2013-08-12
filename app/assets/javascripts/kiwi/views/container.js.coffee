class FK.Views.Container extends Backbone.Marionette.Layout
  template: FK.Template('container')
  className: "row-fluid"
  regions: 
    main_body: '#main_body'
    sidebar:   '#sidebar'

  initialize: =>
    FK.App.on('new-event',@newEvent)
    FK.App.on('all-events',@allEvents)

  onRender: -> 
   @main_body.show(new FK.Views.Events()) 
   @sidebar.show(new FK.Views.Sidebar()) 

  newEvent: (e) =>
    @main_body.show(new FK.Views.EventForm()) 

  allEvents: (e) =>
    @main_body.show(new FK.Views.Events()) 
