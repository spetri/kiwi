class FK.Views.Layout extends Backbone.Marionette.Layout
  template: FK.Template('layout')
  regions:
    navbar:    '#navbar'
    container: '#container'

  onRender: ->
    @navbar.show(new FK.Views.Navbar())
    @container.show(new FK.Views.Container())


class FK.Views.Navbar extends Backbone.Marionette.ItemView
  className: "navbar-inner"
  template: FK.Template('navbar')

class FK.Views.Container extends Backbone.Marionette.Layout
  template: FK.Template('container')
  className: "row-fluid"
  regions: 
    main_body: '#main_body'
    sidebar:   '#sidebar'

  onRender: -> 
   @main_body.show(new FK.Views.Events()) 
   @sidebar.show(new FK.Views.Sidebar()) 



class FK.Views.Events extends Backbone.Marionette.ItemView
  className: "row-fluid"
  template: FK.Template('events')

class FK.Views.Sidebar extends Backbone.Marionette.ItemView
  className: "well sidebar-nav"
  template: FK.Template('sidebar')

