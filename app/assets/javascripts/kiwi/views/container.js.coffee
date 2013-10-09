class FK.Views.Container extends Backbone.Marionette.Layout
  template: FK.Template('container')
  className: "row-fluid"
  regions: 
    main_body: '#main_body'
    sidebar:   '#sidebar'

  initialize: =>
    FK.App.vent.on('container:load',@load)

  onRender: -> 
   @main_body.show(new FK.Views.Events()) 
   @sidebar.show(new FK.Views.Sidebar()) 

  load: (action) =>
    @[action]()

  new: (e) =>
    if FK.CurrentUser.get('logged_in')
      @main_body.show(new FK.Views.EventForm()) 

  all: (e) =>
    @main_body.show(new FK.Views.Events()) 
