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
      'change:subkasts': 'refreshChosenSubkast'

    refreshChosenSubkast: (model) =>
      @$('select').val model.getSingleSubkast()

    renderSubkastOptions: () =>
      _.each(Sidebar.subkasts.namesAndCodes(), (option) =>
        @$('[name="subkast"]').append('<option value="' + option.code + '">' + option.name + '</option>')
      )

    onRender: =>
      @renderSubkastOptions()
      @refreshChosenSubkast(@model)
