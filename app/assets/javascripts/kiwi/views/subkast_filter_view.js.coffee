FK.App.module "Navbar", (Navbar, App, Backbone, Marionette, $, _) ->
  class Navbar.SubkastFilterView extends Marionette.ItemView
    className: 'filter subkast-filter'
    template: FK.Template('subkast_filter')
    events:
      'click .btn': 'save'

    save: (e) =>
      @trigger 'subkasts:save', @$('[type="checkbox"]:checked').map((i, subkast) =>
        $(subkast).attr('name')
      ).toArray()

    renderSubkastOptions: () =>
      _.each(App.request('subkastOptionsAsArray'), (subkast) =>
        @$('.checkbox-container').append('<div class="subkast-option"><label class="subkast-option"><input type="checkbox" name="' + subkast.value + '" /> ' + subkast.option + '</label></div>')
      )

    onRender: =>
      @renderSubkastOptions()
