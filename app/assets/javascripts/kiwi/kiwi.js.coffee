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
FK.App.addRegions({ layout: '#layout' })

@init = (prefetch) ->  
  FK.Data.events = new FK.Collections.EventList(prefetch.events)
  # TODO: use a proper callback
  FK.Data.events.fetch(
    success: =>
      FK.Data.countries = new FK.Collections.CountryList(prefetch.countries)
      FK.App.layout.show(new FK.Views.Layout())
      FK.App.appRouter = new FK.Routers.AppRouter()
      Backbone.history.start() if (!Backbone.History.started)
    )

FK.Controllers.MainController = { 
  events: (action) -> 
    FK.App.vent.trigger('container:load',action)

  default: ->
    Backbone.history.navigate('events/all', trigger: true)
}

class FK.Routers.AppRouter extends Backbone.Marionette.AppRouter
  controller: FK.Controllers.MainController
  appRoutes: {
    '':               'default'
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
});


class FK.Utils.RenderHelpers 
  @populate_select_getter: (view, property, collection, label) ->                                                                                                                                                                                                                                                                                                           
    view.$el.find("select[name=#{property}]").html(collection.map((item) =>
      selected = (if (view.model.get(property) is item.get('_id')) then " selected=\"selected\" " else "") 
      "<option value=\"#{item.get('_id')}\" #{selected} >#{item.get(label)}</option>").join())
