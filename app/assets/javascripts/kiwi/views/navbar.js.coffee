FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @navbarViewModel = new Navbar.NavbarViewModel
       username: @currentUser.get('username')

    @navbarView = new Navbar.NavbarView
      username: @currentUser.get('username')
      model: @navbarViewModel

    @layout = new Navbar.NavbarLayout
    @layout.on 'show', =>
      @layout.navbarRegion.show @navbarView

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
      navbarRegion: '#navbar-region'
    className: 'navbar-container'

  class Navbar.NavbarView extends Backbone.Marionette.ItemView
    className: "navbar navbar-fixed-top"
    template: FK.Template('navbar')

    triggers:
      'click [data-option="country"]': 'clicked:filter:country'
      'click [data-option="subkast"]': 'clicked:filter:subkast'

    initialize: () =>
      @listenTo App.vent, 'container:new', @refreshHighlightNew
      @listenTo App.vent, 'container:show', @refreshHighlight

    refreshHighlight: (option) =>
      @$('[data-option]').removeClass('active')
      @$('[data-option="' + option + '"]').addClass('active')

    refreshHighlightNew: () =>
      @refreshHighlight 'new'
