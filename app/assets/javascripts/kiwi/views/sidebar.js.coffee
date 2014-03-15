FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.Sidebar extends Marionette.Layout
    template: FK.Template('sidebar')
    className: 'sidebar'
    regions:
      event_list: '#sidebar-event-list'
      country_filter: '#country-filter'
      subkast_filter: '#subkast-filter'

    modelEvents:
      'change:subkasts': 'refreshSubkastTitle'
      'change:countryName': 'refreshCountryTitle'

    refreshSubkastTitle: (model, subkasts) =>
      if (subkasts.length == 6)
        @$('.subkast-title').html('All Subkasts')
      else
        @$('.subkast-title').html('Some Subkasts Removed')

    refreshCountryTitle: (model, country) =>
      @$('.country-title').html(country)


    initialize: =>
      @eventListView = new EventList.SidebarEventList
        collection: @collection


      @subkastFilterView = new EventList.SubkastFilterView
        model: @model

      @.on 'clicked:filter:subkast', @toggleSubkastFilterView
      @listenTo App.vent, 'filter:subkasts', @model.setSubkasts
      @listenTo @subkastFilterView, 'subkasts:save', @filterSubkasts
      @listenTo @subkastFilterView, 'subkasts:save', @toggleSubkastFilterView


      @countryFilterView = new EventList.CountryFilterView
        model: @model

      @.on 'clicked:filter:country', @toggleCountryFilterView
      @listenTo App.vent, 'filter:country', @model.setCountry
      @listenTo @countryFilterView, 'country:save', @filterCountry
      @listenTo @countryFilterView, 'country:save', @toggleCountryFilterView

    onRender: =>
      @refreshSubkastTitle(@model, @model.get('subkasts'))
      @refreshCountryTitle(@model, @model.get('countryName'))
      @event_list.show @eventListView
      @country_filter.show @countryFilterView
      @subkast_filter.show @subkastFilterView

    @toggleCountryFilterView = () =>
      if @country_filter.currentView
        @country_filter.close()
      else
        @country_filter.show @countryFilterView
        @countryFilterView.delegateEvents()

    @toggleSubkastFilterView = () =>
      if @subkast_filter.currentView
        @subkast_filter.close()
      else
        @subkast_filter.show @subkastFilterView
        @subkastFilterView.delegateEvents()

    @filterSubkasts = (subkasts) =>
      @model.setSubkasts subkasts
      App.vent.trigger 'filter:subkasts', subkasts

    @filterCountry = (country) =>
      @model.setCountry country
      App.vent.trigger 'filter:country', country

  class EventList.SidebarEventList extends Marionette.CompositeView
    template: FK.Template('sidebar_event_list')
    className: 'top-ranked'
    itemView: EventList.EventName
    itemViewContainer: 'ul.events'
