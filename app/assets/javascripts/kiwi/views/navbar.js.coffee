FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show

  @show = () ->
    @close() if @view

    @view = new Navbar.NavbarView
      model: App.request 'currentUser'
    
    App.navbarRegion.show @view

  @close = () ->
    @view.close()

  class Navbar.NavbarView extends Backbone.Marionette.ItemView
    className: "navbar-inner"
    template: FK.Template('navbar')

    initialize: () =>
      @listenTo App.vent, 'container:all', @refreshHighlightAll
      @listenTo App.vent, 'container:new', @refreshHighlightNew

    refreshHighlight: (option) =>
      @$('[data-option]').removeClass('active')
      @$('[data-option="' + option + '"]').addClass('active')

    refreshHighlightAll: () =>
      @refreshHighlight 'all'

    refreshHighlightNew: () =>
      @refreshHighlight 'new'

