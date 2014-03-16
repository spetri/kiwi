FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->
  class EventList.CountryFilterView extends Marionette.ItemView
    template: FK.Template('country_filter')
    className: 'country-filter filter'
    events:
      'change select': 'save'

    save: (e) =>
      @trigger('country:save', @$('option:selected').val())

    modelEvents:
      'change:country': 'refreshChosenCountry'

    refreshChosenCountry: (model, country) =>
      @$('select').val country

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @refreshChosenCountry(@model, @model.get('country'))
