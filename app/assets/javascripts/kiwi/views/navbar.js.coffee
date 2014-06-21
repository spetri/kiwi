FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @config = App.request 'eventConfig'

    @navbarViewModel = new Navbar.NavbarViewModel
       username: @currentUser.get('username')

    @navbarViewModel.set('username', null) if not @currentUser.get('logged_in')

    @listenTo @config, 'change:subkasts', @hideShowSubkastView

    @navbarView = new Navbar.NavbarView
      username: @currentUser.get('username')
      model: @navbarViewModel

    @subkastNavView = new Navbar.NavbarSubkastView
      model: @config

    @sidebar = App.Sidebar.create(@sidebarConfig)

    @listenTo @navbarView, 'click:home', @goHome
    @listenTo @subkastNavView, 'click:subkast', @goToEventList

    @layout = new Navbar.NavbarLayout
    @layout.on 'show', =>
      @layout.navbar.show @navbarView
      @hideShowSubkastView(@config)

    @navbarView.on 'show', =>
      @navbarView.mobileSidebarRegion.show @sidebar.layout

  @show = () ->
    App.navbarRegion.show @layout

  @goHome = () =>
    App.vent.trigger 'container:all'
    App.request('eventStore').filterBySubkasts('ALL')

  @goToEventList = () =>
    App.vent.trigger 'container:all'

  @hideShowSubkastView = (config) =>
    if config.getSingleSubkast() is 'ALL'
      @layout.navbarSubkastRegion.close()
      @layout.shrink()
    else
      @layout.navbarSubkastRegion.show @subkastNavView
      @subkastNavView.refreshSubkast(@config)
      @subkastNavView.delegateEvents()
      @layout.grow()

  @close = () ->
    @view.close()

  class Navbar.NavbarLayout extends Marionette.Layout
    template: FK.Template('navbar_layout')
    regions:
      navbar: '#navbar-navbar-region'
      navbarSubkastRegion: '#navbar-subkast-region'
    className: 'navbar-indom-container'

    grow: () =>
      @$el.css('height', '105px')

    shrink: () =>
      @$el.css('height', '')

  class Navbar.NavbarView extends Marionette.Layout
    className: "navbar navbar-fixed-top forekast-navbar"
    template: FK.Template('navbar')

    regions:
      'mobileSidebarRegion': '#mobile-sidebar'

    triggers:
      'click .navbar-brand': 'click:home'

    events:
      'click .add-new': 'goToForm'

    goToForm: (e) =>
      e.preventDefault()
      App.vent.trigger 'container:new'

    initialize: () =>
      @listenTo App.vent, 'container:new', @refreshHighlightNew
      @listenTo App.vent, 'container:show', @refreshHighlight

    refreshHighlight: (option) =>
      @$('[data-option]').removeClass('active')
      @$('[data-option="' + option + '"]').addClass('active')

    refreshHighlightNew: () =>
      @refreshHighlight 'new'
      
  class Navbar.NavbarSubkastView extends Marionette.ItemView
    className: 'navbar navbar-fixed-top subkast-navbar'
    template: FK.Template('navbar_subkast')

    triggers:
      'click .subkast-header-link': 'click:subkast'

    modelEvents:
      'change:subkasts': 'refreshSubkast'

    refreshSubkast: (model, subkast) =>
      link = '/' + _.invert(FK.Data.urlToSubkast)[model.getSingleSubkast()]
      @$('.subkast-header-link').attr('href', link)
      subkastText = _.invert(FK.Data.urlToSubkast)[model.getSingleSubkast()]
      @$('.subkast').text(subkastText)

  class Navbar.NavbarViewModel extends Backbone.Model
    defaults:
      username: null
