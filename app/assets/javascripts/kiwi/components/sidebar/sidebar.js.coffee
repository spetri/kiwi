FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  @create = (startupData) ->

    @subkasts = startupData.subkasts

    @model = App.request('eventConfig')

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

      @countryFilterView = new Sidebar.CountryFilterView
        model: @model

      @subkastFilterView = new Sidebar.SubkastFilterView
        model: @model

    onShow: =>
      @event_list.show @eventListView
      @country_filter.show @countryFilterView
      @subkast_filter.show @subkastFilterView
