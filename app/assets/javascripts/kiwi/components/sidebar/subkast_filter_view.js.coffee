FK.App.module "Sidebar", (Sidebar, App, Backbone, Marionette, $, _) ->
  class Sidebar.SubkastFilterView extends Marionette.ItemView
    className: 'filter subkast-filter'
    template: FK.Template('subkast_filter')
    events:
      'change input': 'save'

    modelEvents:
      'change:subkasts': 'refreshChosenSubkast'

    save: (e) =>
      subkasts = @$('[type="checkbox"]:checked').map((i, subkast) =>
        $(subkast).attr('name')
      ).toArray()
      @model.setSubkasts subkasts

    renderSubkastOptions: () =>
      FK.Utils.RenderHelpers.populate_checkboxes_from_array(@,
        '.checkbox-container',
        App.request('subkastOptionsAsArray'), 'subkast-option')

    refreshChosenSubkast: (model, subkasts) =>
      @$("input[type=checkbox]").prop('checked', false)
      _.each subkasts, (subkast) =>
        @$("[name=\"#{subkast}\"]").prop('checked', true)

    onRender: =>
      @renderSubkastOptions()
      @refreshChosenSubkast @model, @model.get('subkasts')
