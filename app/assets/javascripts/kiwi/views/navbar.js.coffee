FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @navbarViewModel = new Navbar.NavbarViewModel
       username: @currentUser.get('username')

    @navbarViewModel.set('username', null) if not @currentUser.get('logged_in')

    @navbarView = new Navbar.NavbarView
      username: @currentUser.get('username')
      model: @navbarViewModel


    @layout = new Navbar.NavbarLayout
    @layout.on 'show', =>
      @layout.navbar.show @navbarView

  @show = () ->
    App.navbarRegion.show @layout

  @close = () ->
    @view.close()

  class Navbar.NavbarViewModel extends Backbone.Model
    defaults:
      username: null


  class Navbar.NavbarLayout extends Marionette.Layout
    template: FK.Template('navbar_layout')
    regions:
      navbar: '#navbar-region'
    className: 'navbar-container'

  class Navbar.NavbarView extends Backbone.Marionette.ItemView
    className: "navbar navbar-fixed-top"
    template: FK.Template('navbar')


    initialize: () =>
      @listenTo App.vent, 'container:new', @refreshHighlightNew
      @listenTo App.vent, 'container:show', @refreshHighlight

    refreshHighlight: (option) =>
      @$('[data-option]').removeClass('active')
      @$('[data-option="' + option + '"]').addClass('active')

    refreshHighlightNew: () =>
      @refreshHighlight 'new'

    onShow: () =>
      @sidebar = App.Sidebar.create(@sidebarConfig)
      @$("#mobile-sidebar").html(@sidebar.layout.render().el)
