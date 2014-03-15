FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->
  class EventList.SubkastFilterView extends Marionette.ItemView
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

    refreshChosenSubkast: (model, subkasts) =>
      _.each subkasts, (subkast) =>
        @$('[name="' + subkast + '"]').prop('checked', true)

    refreshSaveButton: (model, username) =>
      if username
        @$('.save-button').text('Save')
      else
        @$('.save-button').text('Apply')

    onRender: =>
      @renderSubkastOptions()
      @refreshChosenSubkast @model, @model.get('subkasts')
      @refreshSaveButton @model, @model.get('username')

  
