FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->

  @addInitializer () ->
    @listenTo App, 'start', @show
    @currentUser = App.request 'currentUser'

    @config = App.request 'eventConfig'

    @navbarViewModel = new Navbar.NavbarViewModel
       username: @currentUser.get('username')

    @navbarViewModel.set('username', null) if not @currentUser.get('logged_in')

    @listenTo App.vent, 'container:all', @showSubkastView
    @listenTo App.vent, 'container:show container:new', @hideSubkastView
    @listenTo @config, 'change:subkasts', @showSubkast
    @listenTo @config, 'change:subkasts', @refreshHomeLink

    @navbarView = new Navbar.NavbarView
      username: @currentUser.get('username')
      model: @navbarViewModel

    @layout = new Navbar.NavbarLayout
    @layout.on 'show', =>
      @layout.navbar.show @navbarView

  @show = () ->
    App.navbarRegion.show @layout

  @showSubkastView = () =>
    @subkastNavView = new Navbar.NavbarSubkastView
    @layout.navbarSubkastRegion.show @subkastNavView
    @layout.grow()
    @showSubkast(@config)

  @hideSubkastView = () =>
    @layout.navbarSubkastRegion.close()
    @layout.shrink()

  @showSubkast = (model) =>
    @subkastNavView.showSubkast _.invert(FK.Data.urlToSubkast)[model.getSingleSubkast()]

  @refreshHomeLink = (model) =>
    @navbarView.refreshHomeLink _.invert(FK.Data.urlToSubkast)[model.getSingleSubkast()]

  @close = () ->
    @view.close()

  class Navbar.NavbarSubkastView extends Marionette.ItemView
    className: 'navbar-subkast'
    template: FK.Template('navbar_subkast')

    showSubkast: (subkast) =>
      @$('.subkast').text(subkast)

  class Navbar.NavbarViewModel extends Backbone.Model
    defaults:
      username: null

  class Navbar.NavbarLayout extends Marionette.Layout
    template: FK.Template('navbar_layout')
    regions:
      navbar: '#navbar-region'
      navbarSubkastRegion: '#navbar-subkast-region'
    className: 'navbar-container'

    grow: =>
      @$el.parent().css('height', '90px')

    shrink: =>
      @$el.parent().css('height', '')

  class Navbar.NavbarView extends Marionette.Layout
    className: "navbar navbar-fixed-top"
    template: FK.Template('navbar')

    events:
      'click .navbar-brand': 'goHome'
      'click .add-new': 'goToForm'

    goHome: (e) =>
      e.preventDefault()
      App.vent.trigger 'container:all'

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

    refreshHomeLink: (link) =>
      @$('a').attr('href', '/' + link)

    onShow: () =>
      @sidebar = App.Sidebar.create(@sidebarConfig)
      @$("#mobile-sidebar").html(@sidebar.layout.render().el)
