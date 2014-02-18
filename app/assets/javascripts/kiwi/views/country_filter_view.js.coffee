FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->
  class Navbar.CountryFilterView extends Marionette.ItemView
    template: FK.Template('country_filter')
    className: 'country-filter filter'
    triggers:
      'click .btn': 'clicked:save'

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
