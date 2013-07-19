class FK.Views.Container extends Backbone.Marionette.Layout
  template: FK.Template('container')
  className: "row-fluid"
  regions: 
    main_body: '#main_body'
    sidebar:   '#sidebar'

  onRender: -> 
   @main_body.show(new FK.Views.Events()) 
   @sidebar.show(new FK.Views.Sidebar()) 

