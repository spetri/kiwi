FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @config = App.request 'eventConfig'

    @navbarViewModel = new Navbar.NavbarViewModel
       username: @currentUser.get('username')

    @navbarViewModel.set('username', null) if not @currentUser.get('logged_in')

    @listenTo App.vent, 'container:show container:new', @hideSubkastView
    @listenTo @config, 'change:subkasts', @showSubkast

    @navbarView = new Navbar.NavbarView
      username: @currentUser.get('username')
      model: @navbarViewModel

    @subkastNavView = new Navbar.NavbarSubkastView

    @listenTo @navbarView, 'click:home', @goHome
    @listenTo @subkastNavView, 'click:subkast', @goToEventList

    @layout = new Navbar.NavbarLayout
    @layout.on 'show', =>
      @layout.navbar.show @navbarView
      @layout.navbarSubkastRegion.show @subkastNavView
      @showSubkastView()

  @show = () ->
    App.navbarRegion.show @layout

  @showSubkastView = () =>
    @showSubkast(@config)

  @showSubkast = (model) =>
    @subkastNavView.showSubkast _.invert(FK.Data.urlToSubkast)[model.getSingleSubkast()]
    @subkastNavView.refreshSubkastLink('/' + _.invert(FK.Data.urlToSubkast)[model.getSingleSubkast()])

  @goHome = () =>
    App.vent.trigger 'container:all'
    App.request('eventStore').filterBySubkasts('ALL')

  @goToEventList = () =>
    App.vent.trigger 'container:all'

  @close = () ->
    @view.close()

  class Navbar.NavbarSubkastView extends Marionette.ItemView
    className: 'navbar-subkast'
    template: FK.Template('navbar_subkast')

    triggers:
      'click .subkast-header-link': 'click:subkast'

    showSubkast: (subkast) =>
      @$('.subkast').text(subkast)

    refreshSubkastLink: (link) =>
      @$('.subkast-header-link').attr('href', link)

  class Navbar.NavbarViewModel extends Backbone.Model
    defaults:
      username: null

  class Navbar.NavbarLayout extends Marionette.Layout
    template: FK.Template('navbar_layout')
    regions:
      navbar: '#navbar-region'
      navbarSubkastRegion: '#navbar-subkast-region'
    className: 'navbar-container'

  class Navbar.NavbarView extends Marionette.Layout
    className: "navbar navbar-fixed-top"
    template: FK.Template('navbar')

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

    onShow: () =>
      @sidebar = App.Sidebar.create(@sidebarConfig)
      @$("#mobile-sidebar").html(@sidebar.layout.render().el)
