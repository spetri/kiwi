FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->
  # TODO: refactor Sidebar into its own module, have EventList compose it
  class EventList.Sidebar extends Marionette.Layout
    template: FK.Template('sidebar')
    className: 'sidebar'
    regions:
      event_list: '#sidebar-event-list'
      country_filter: '#country-filter'
      subkast_filter: '#subkast-filter'

    initialize: =>
      @eventListView = new EventList.SidebarEventList
        collection: @collection

      @subkastFilterView = new EventList.SubkastFilterView
        model: @model

      @countryFilterView = new EventList.CountryFilterView
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

  class EventList.SidebarEventList extends Marionette.CompositeView
    template: FK.Template('sidebar_event_list')
    className: 'top-ranked'
    itemView: EventList.EventName
    itemViewContainer: 'ul.events'
