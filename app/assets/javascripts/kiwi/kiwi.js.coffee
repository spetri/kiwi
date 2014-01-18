window.FK = {
  Data:{}
  Views:{}
  Models:{}
  Collections:{}
  Configs: {}
  Controllers: {}
  Routers: {}
  Utils: {}
}

FK.Template = (file) ->
  JST["kiwi/templates/#{file}"]

FK.Uri = (uri) ->
  Backbone.history.fragment is uri

FK.App = new Backbone.Marionette.Application()
FK.App.addRegions({
  navbarRegion: '#navbar-region'
  mainRegion: '#main-region'
})

FK.App.addInitializer (prefetch) ->
  FK.Links = prefetch.links
  FK.CurrentUser = new FK.Models.User(prefetch.user)

  if prefetch.user != null
    FK.CurrentUser.set(logged_in: true, silent: true)

  FK.Data.countries = new FK.Collections.CountryList(prefetch.countries)

  FK.Data.EventStore = new FK.EventStore prefetch.events
  FK.Data.EventStore.fetchStartupEvents()

  FK.App.appRouter = new FK.Routers.AppRouter()


FK.Controllers.MainController = {
  events: (action) ->
    FK.App.vent.trigger('container:' + action)

  show: (id) ->
    event = new FK.Models.Event
      _id: id
    event.fetch().done =>
      FK.App.vent.trigger('container:show', event)

  edit: (id) ->
    event = new FK.Models.Event
      _id: id
    event.fetch().done =>
      FK.App.vent.trigger('container:new', event)

  default: ->
    Backbone.history.navigate('events/all', trigger: true)
}

FK.App.reqres.setHandler 'events', () ->
  FK.Data.EventStore.events

FK.App.reqres.setHandler 'eventStore', () ->
  FK.Data.EventStore

FK.App.reqres.setHandler 'currentUser', () ->
  FK.CurrentUser

FK.App.reqres.setHandler 'countryName', (countryCode) ->
  FK.Data.countries.get(countryCode).get('en_name').trim()

class FK.Routers.AppRouter extends Backbone.Marionette.AppRouter
  controller: FK.Controllers.MainController
  appRoutes: {
    '':               'default'
    '_=_':            'default' # facebook callback route
    'events/show/:id':    'show'
    'events/edit/:id':  'edit'
    'events/:action': 'events'
  }

moment.lang('en', {
    calendar : {
        lastDay : '[Yesterday at] LT',
        sameDay : '[Today at] LT',
        nextDay : '[Tomorrow at] LT',
        lastWeek : '[last] dddd [at] LT',
        nextWeek : 'dddd [at] LT',
        sameElse : 'dddd, MMMM D '
    }
})

class FK.Utils.RenderHelpers
  @populate_select_getter: (view, property, collection, label) ->
    view.$el.find("select[name=#{property}]").html(collection.map((item) =>
      selected = (if (view.model && view.model.get(property) is item.get('_id')) then " selected=\"selected\" " else "")
      "<option value=\"#{item.get('_id')}\" #{selected} >#{item.get(label)}</option>").join())
