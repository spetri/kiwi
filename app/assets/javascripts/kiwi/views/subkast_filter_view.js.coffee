FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->
  class Navbar.SubkastFilterView extends Marionette.ItemView
    className: 'filter subkast-filter'
    template: FK.Template('subkast_filter')
    triggers:
      'click .btn': 'clicked:save'

    renderSubkastOptions: () =>
      _.each(App.request('subkastOptionsAsArray'), (subkast) =>
        @$('.checkbox-container').append('<div class="subkast-option"><label class="subkast-option"><input type="checkbox" name="' + subkast.value + '" /> ' + subkast.option + '</label></div>')
      )

    onRender: =>
      @renderSubkastOptions()
