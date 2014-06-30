FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  @create = (startupData) ->

    @subkasts = startupData.subkasts
    @config = App.request('eventConfig')

    @layout = new Sidebar.Layout
      collection: App.request('eventStore').topRanked,
      model: @config

    @eventListView = new Sidebar.EventList
      collection: @collection

    @countryFilterView = new Sidebar.CountryFilterView
      model: @config

    @subkastFilterView = new Sidebar.SubkastFilterView
      model: @config
      collection: @subkasts

    @layout.on 'show', =>
      @layout.event_list.show @eventListView
      @layout.country_filter.show @countryFilterView
      @layout.subkast_filter.show @subkastFilterView

    @instance = new Sidebar.Controller
      layout: @layout

    @listenTo @eventListView, 'itemview:clicked:event', (event) ->
      App.vent.trigger 'container:show', event.model

    @listenTo @subkastFilterView, 'subkast:clicked', (args) ->
      @config.setSubkast(args.model.get('code'))

    return @instance

  class Sidebar.Controller extends Marionette.Controller
    initialize: (options) =>
      @layout = options.layout

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
