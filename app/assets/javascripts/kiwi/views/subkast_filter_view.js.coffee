FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->
  class EventList.SubkastFilterView extends Marionette.ItemView
    className: 'filter subkast-filter'
    template: FK.Template('subkast_filter')
    events:
      'change input': 'save'

    save: (e) =>
      @trigger 'subkasts:save', @$('[type="checkbox"]:checked').map((i, subkast) =>
        $(subkast).attr('name')
      ).toArray()

    renderSubkastOptions: () =>
      FK.Utils.RenderHelpers.populate_checkboxes_from_array(@,
        '.checkbox-container',
        App.request('subkastOptionsAsArray'), 'subkast-option')

    refreshChosenSubkast: (model, subkasts) =>
      _.each subkasts, (subkast) =>
        @$("[name=\"#{subkast}\"]").prop('checked', true)

    onRender: =>
      @renderSubkastOptions()
      @refreshChosenSubkast @model, @model.get('subkasts')
