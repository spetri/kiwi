FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->
  class EventList.CountryFilterView extends Marionette.ItemView
    template: FK.Template('country_filter')
    className: 'country-filter filter'
    events:
      'click .btn': 'save'

    save: (e) =>
      @trigger('country:save', @$('option:selected').val())

    modelEvents:
      'change:country': 'refreshChosenCountry'

    refreshChosenCountry: (model, country) =>
      @$('select').val country

    refreshSaveButton: (model, username) =>
      if username
        @$('.save-button').text('Save')
      else
        @$('.save-button').text('Apply')

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @refreshChosenCountry(@model, @model.get('country'))
      @refreshSaveButton(@model, @model.get('username'))
