FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  @create = (sidebarConfig) ->
    sidebarConfig = {} if not sidebarConfig

    @user = App.request('currentUser')

    @model = new Sidebar.ViewModel
      username: @user

    _.defaults(sidebarConfig, @user.pick('country', 'subkasts'))

    # if we have a configuration, load it:
    @model.set(sidebarConfig)

    @layout =  new Sidebar.Layout
      collection: App.request('eventStore').topRanked,
      model: @model

    @instance = new Sidebar.Controller
      model: @model
      layout: @layout

    @listenTo @layout.eventListView, 'itemview:clicked:event', (event) ->
      App.vent.trigger 'container:show', event.model

    return @instance

  class Sidebar.Controller extends Marionette.Controller
    initialize: (options) =>
      @model = options.model
      @layout = options.layout

    value: () =>
      @.model.toJSON()

  class Sidebar.EventName extends Marionette.ItemView
    template: FK.Template('event_name')
    tagName: 'a'
    className: 'event-name'
    triggers:
      'click': 'clicked:event'

  class Sidebar.EventList extends Marionette.CompositeView
    template: FK.Template('sidebar_event_list')
    className: 'top-ranked'
    itemView: Sidebar.EventName
    itemViewContainer: 'ul.events'

  class Sidebar.Layout extends Marionette.Layout
    template: FK.Template('sidebar')
    className: 'sidebar'
    regions:
      event_list: '#sidebar-event-list'
      country_filter: '#country-filter'
      subkast_filter: '#subkast-filter'

    initialize: =>
      @eventListView = new Sidebar.EventList
        collection: @collection
      @subkastFilterView = new Sidebar.SubkastFilterView
        model: @model

      @countryFilterView = new Sidebar.CountryFilterView
        model: @model

      # listen to filtering changes in the rest of the application:
      @listenTo App.vent, 'filter:subkasts', @model.setSubkasts
      @listenTo App.vent, 'filter:country', @model.setCountry

      # notify the rest of the application:
      @listenTo @model, 'change:subkasts', @notifySubkastChange
      @listenTo @model, 'change:country', @notifyCountryChange

    notifySubkastChange: (model, subkasts) =>
      App.vent.trigger 'filter:subkasts', subkasts

    notifyCountryChange: (model, country) =>
      App.vent.trigger 'filter:country', country

    onRender: =>
      @event_list.show @eventListView
      @country_filter.show @countryFilterView
      @subkast_filter.show @subkastFilterView

  class Sidebar.ViewModel extends Backbone.Model
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

