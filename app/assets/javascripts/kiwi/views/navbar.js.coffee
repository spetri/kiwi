FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show

    @currentUser = App.request 'currentUser'
    @subkasts = App.request 'subkasts'
    @config = App.request 'eventConfig'
    @eventStore = App.request 'eventStore'

    @navbarViewModel = new Navbar.NavbarViewModel
       username: @currentUser.get('username')

    @navbarViewModel.set('username', null) if not @currentUser.get('logged_in')

    @listenTo @config, 'change:subkasts', @hideShowSubkastView

    @navbarView = new Navbar.NavbarView
      username: @currentUser.get('username')
      model: @navbarViewModel

    @navbarSeparator = new Navbar.NavbarSeparatorView

    @subkastNavView = new Navbar.NavbarSubkastView
      model: @config

    @sidebar = App.Sidebar.create(@buildSubkastConfig())

    @listenTo @navbarView, 'click:home', @goHome
    @listenTo @subkastNavView, 'click:subkast', @goToEventList

    @layout = new Navbar.NavbarLayout
    @layout.on 'show', =>
      @layout.navbar.show @navbarView
      @hideShowSubkastView(@config)

    @layout.on 'show', =>
      @layout.navbarSeparatorView.show @navbarSeparator

    @navbarView.on 'show', =>
      @navbarView.mobileSidebarRegion.show @sidebar.layout

  @buildSubkastConfig = () =>
    {
      subkasts: @subkasts
      config: @config
      topRanked: @eventStore.topRanked
    }

  @show = () ->
    App.navbarRegion.show @layout

  @goHome = () =>
    App.vent.trigger 'container:all'
    @eventStore.filterBySubkasts('ALL')
    App.request('eventStore').fetchStartupEvents()

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
      navbarSeparatorView: '#navbar-separator-region'
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
      'click .logo': 'click:home'

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

    onRender: () =>
      @$('.what-is-global').tooltip(title: 'Global events are those that aren\'t restricted by location - events people can watch, listen to, or take part in no matter where they live.', placement: 'bottom' )


  class Navbar.NavbarSeparatorView extends Marionette.ItemView
    className: "outer"
    template: FK.Template('navbar_separator')

  class Navbar.NavbarSubkastView extends Marionette.ItemView
    className: 'navbar navbar-fixed-top subkast-navbar'
    template: FK.Template('navbar_subkast')

    triggers:
      'click .subkast-header-link': 'click:subkast'

    modelEvents:
      'change:subkasts': 'refreshSubkast'

    refreshSubkast: (model, subkast) =>
      link = Navbar.subkasts.getUrlByCode(model.getSingleSubkast())
      @$('.subkast-header-link').attr('href', '/' + link)
      @$('.subkast').text(link)

  class Navbar.NavbarViewModel extends Backbone.Model
    defaults:
      username: null
