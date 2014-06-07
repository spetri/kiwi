FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.SubkastFilterView extends Marionette.ItemView
    template: FK.Template('subkast_filter')
    className: 'subkast-filter filter'
    events:
      'change select': 'save'

    save: (e) =>
      subkast = @$('option:selected').val()
      @model.setSubkast subkast

    modelEvents:
      'change:subkast': 'refreshChosenSubkast'

    refreshChosenSubkast: (model) =>
      @$('select').val model.getSingleSubkast()

    renderSubkastOptions: () =>
      _.each(App.request('subkastOptionsAsArray'), (option) =>
        @$('[name="subkast"]').append('<option value="' + option.value + '">' + option.option + '</option>')
      )

    onRender: =>
      @renderSubkastOptions()
      @refreshChosenSubkast(@model)
