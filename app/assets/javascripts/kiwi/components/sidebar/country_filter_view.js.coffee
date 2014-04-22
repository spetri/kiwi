FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.CountryFilterView extends Marionette.ItemView
    template: FK.Template('country_filter')
    className: 'country-filter filter'
    events:
      'change select': 'save'

    save: (e) =>
      country = @$('option:selected').val()
      @model.setCountry country

    modelEvents:
      'change:country': 'refreshChosenCountry'

    refreshChosenCountry: (model, country) =>
      @$('select').val country

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @refreshChosenCountry(@model, @model.get('country'))
      @$('sup').tooltip({title:'Some events are only relevant within a certain country such as a national holiday or tv show time. Everyone can see event with the Global label.'});
