FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @layout = new Navbar.NavbarLayout
    @navbarView = new Navbar.NavbarView
      model: @currentUser
    @countryFilterView = new Navbar.CountryFilterView
    @subkastFilterView = new Navbar.SubkastFilterView

    @layout.on 'show', =>
      @layout.navbarRegion.show @navbarView
      @layout.countryFilterRegion.show @countryFilterView
      @layout.subkastFilterRegion.show @subkastFilterView

  @show = () ->
    App.navbarRegion.show @layout

  @close = () ->
    @view.close()

  class Navbar.NavbarLayout extends Marionette.Layout
    template: FK.Template('navbar_layout')
    regions:
      navbarRegion: '#navbar-region'
      countryFilterRegion: '#country-filter-region'
      subkastFilterRegion: '#subkast-filter-region'
    className: 'navbar-container'

  class Navbar.NavbarView extends Backbone.Marionette.ItemView
    className: "navbar navbar-inverse navbar-fixed-top"
    template: FK.Template('navbar')

    initialize: () =>
      @listenTo App.vent, 'container:new', @refreshHighlightNew
      @listenTo App.vent, 'container:show', @refreshHighlight

    refreshHighlight: (option) =>
      @$('[data-option]').removeClass('active')
      @$('[data-option="' + option + '"]').addClass('active')

    refreshHighlightNew: () =>
      @refreshHighlight 'new'
