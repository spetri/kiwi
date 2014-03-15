FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @navbarModel = new Navbar.NavbarModel
      username: @currentUser.get('username')

    @navbarModel.setCountry(@currentUser.get('country')) if @currentUser.get('country')
    @navbarModel.setSubkasts(@currentUser.get('subkasts')) if @currentUser.get('subkasts')
    @navbarModel.set('username', null) if not @currentUser.get('logged_in')

    @layout = new Navbar.NavbarLayout
    @navbarView = new Navbar.NavbarView
      model: @navbarModel
    @countryFilterView = new Navbar.CountryFilterView
      model: @navbarModel
    @subkastFilterView = new Navbar.SubkastFilterView
      model: @navbarModel

    @navbarView.on 'clicked:filter:country', @toggleCountryFilterView
    @navbarView.on 'clicked:filter:subkast', @toggleSubkastFilterView

    @listenTo @countryFilterView, 'country:save', @filterCountry
    @listenTo @countryFilterView, 'country:save', @toggleCountryFilterView
    @listenTo @subkastFilterView, 'subkasts:save', @filterSubkasts
    @listenTo @subkastFilterView, 'subkasts:save', @toggleSubkastFilterView

    @listenTo App.vent, 'filter:country', @navbarModel.setCountry
    @listenTo App.vent, 'filter:subkasts', @navbarModel.setSubkasts

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

  @filterSubkasts = (subkasts) =>
    @navbarModel.setSubkasts subkasts
    App.vent.trigger 'filter:subkasts', subkasts

  @filterCountry = (country) =>
    @navbarModel.setCountry country
    App.vent.trigger 'filter:country', country

  @close = () ->
    @view.close()

  class Navbar.NavbarModel extends Backbone.Model
    defaults:
      username: null
      country: 'CA'
      countryName: 'Canada'
      subkasts: ['TVM', 'SE', 'ST', 'PRP', 'HA', 'OTH']

    setCountry: (country) =>
      @set 'country', country
      @set 'countryName', App.request('countryName', country)

    setSubkasts: (subkasts) =>
      @set 'subkasts', subkasts
      
  class Navbar.NavbarLayout extends Marionette.Layout
    template: FK.Template('navbar_layout')
    regions:
      navbarRegion: '#navbar-region'
      countryFilterRegion: '#country-filter-region'
      subkastFilterRegion: '#subkast-filter-region'
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

    modelEvents:
      'change:subkasts': 'refreshSubkastTitle'
      'change:countryName': 'refreshCountryTitle'

    refreshSubkastTitle: (model, subkasts) =>
      if (subkasts.length == 6)
        @$('.subkast-title').html('All Subkasts')
      else
        @$('.subkast-title').html('Some Subkasts Removed')

    refreshCountryTitle: (model, country) =>
      @$('.country-title').html(country)

    onRender: =>
      @refreshSubkastTitle(@model, @model.get('subkasts'))
      @refreshCountryTitle(@model, @model.get('countryName'))
