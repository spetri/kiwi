FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

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

      @listenTo App.vent, 'filter:subkasts', @model.setSubkasts
      @listenTo App.vent, 'filter:country', @model.setCountry

      @listenTo @subkastFilterView, 'subkasts:save', @filterSubkasts

      @countryFilterView = new EventList.CountryFilterView
        model: @model

      @listenTo @countryFilterView, 'country:save', @filterCountry

    onRender: =>
      @event_list.show @eventListView
      @country_filter.show @countryFilterView
      @subkast_filter.show @subkastFilterView


    filterSubkasts: (subkasts) =>
      @model.setSubkasts subkasts
      App.vent.trigger 'filter:subkasts', subkasts

    filterCountry: (country) =>
      @model.setCountry country
      App.vent.trigger 'filter:country', country

  class EventList.SidebarEventList extends Marionette.CompositeView
    template: FK.Template('sidebar_event_list')
    className: 'top-ranked'
    itemView: EventList.EventName
    itemViewContainer: 'ul.events'
