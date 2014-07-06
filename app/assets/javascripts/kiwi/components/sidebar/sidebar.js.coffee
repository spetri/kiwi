FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  @create = (startupData) ->
    @instance = new Sidebar.Controller(startupData)
    return @instance

  class Sidebar.Controller extends Marionette.Controller
    initialize: (options) =>
      @subkasts = options.mySubkasts
      @config = options.config
      @topRanked = options.topRanked

      @layout = new Sidebar.Layout

      @eventListView = new Sidebar.EventList
        collection: @topRanked

      @countryFilterView = new Sidebar.CountryFilterView
        model: @config

      @subkastFilterView = new Sidebar.SubkastFilterView
        model: @config
        collection: @subkasts

      @listenTo @eventListView, 'itemview:clicked:event', (args) ->
        @toEvent(args.model)

      @listenTo @subkastFilterView, 'subkast:clicked', (args) ->
        @switchSubkast(args.model)

      @layout.on 'show', =>
        @layout.event_list.show @eventListView
        @layout.country_filter.show @countryFilterView
        @layout.subkast_filter.show @subkastFilterView

    toEvent: (event) =>
      App.vent.trigger 'container:show', event

    switchSubkast: (subkast) =>
      @config.setSubkast(subkast.get('code'))

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
