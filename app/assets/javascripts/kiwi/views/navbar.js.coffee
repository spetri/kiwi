FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @layout = new Navbar.NavbarLayout
    @navbarView = new Navbar.NavbarView
      model: @currentUser
    @countryFilterView = new Navbar.CountryFilterView
    @subkastFilterView = new Navbar.SubkastFilterView

    @navbarView.on 'clicked:filter:country', @toggleCountryFilterView
    @navbarView.on 'clicked:filter:subkast', @toggleSubkastFilterView

    @listenTo @countryFilterView, 'clicked:save', @toggleCountryFilterView
    @listenTo @subkastFilterView, 'clicked:save', @toggleSubkastFilterView

    @layout.on 'show', =>
      @layout.navbarRegion.show @navbarView

  @show = () ->
    App.navbarRegion.show @layout

  @toggleCountryFilterView = () =>
    if @layout.countryFilterRegion.currentView
      @layout.countryFilterRegion.close()
    else
      @layout.countryFilterRegion.show @countryFilterView
      @countryFilterView.delegateEvents()

  @toggleSubkastFilterView = () =>
    if @layout.subkastFilterRegion.currentView
      @layout.subkastFilterRegion.close()
    else
      @layout.subkastFilterRegion.show @subkastFilterView
      @subkastFilterView.delegateEvents()

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
