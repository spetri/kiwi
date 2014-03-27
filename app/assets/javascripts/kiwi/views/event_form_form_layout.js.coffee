FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.FormLayout extends Backbone.Marionette.Layout
    className: "event-form col-md-8"
    template: FK.Template('event_form')

    regions:
      'saveContainerRegion': '.save-container'

    events:
      'change input[name=name]': 'validateName'
      'change input[name=location_type]': 'renderLocation'

    validateName: (e) =>
      @$el.find(".error").remove()
      if $(e.target).val().length > 79
        $("<div class=\"error\">Event is too long</div>").insertAfter(e.target)

    renderLocation: (e) =>
      if @$el.find('input[name=location_type]:checked').val() is "international"
        @$el.find('select[name=country]').attr('disabled','disabled')
      else
        @$el.find('select[name=country]').removeAttr('disabled')

    modelEvents:
      'change:name': 'refreshName'
      'change:subkast': 'refreshSubkast'
      'change:location_type': 'refreshLocation'
      'change:country': 'refreshLocation'
      'change:description': 'refreshDescription'

    refreshName: (event) ->
      @$('#name').val event.get('name')

    refreshSubkast: (event) ->
      @$('[name="subkast"]').val(event.get('subkast'))

    refreshLocation: (event) ->
      @$('[name="location_type"][value="' + event.get('location_type') + '"]').attr('checked', 'checked')
      @$('[name="country"] [value="' + event.get('country') + '"]').attr('selected', 'selected')

    refreshDescription: (event) ->
      @$('[name="description"]').val(event.get('description'))

    value: () ->
      window.serializeForm(
        @$el.find(
          '[name="name"],
           [name="subkast"],
           [name="location_type"],
           [name="country"],
           [name="description"]'
        )
      )

    renderSubkastOptions: () =>
      _.each(App.request('subkastOptionsAsArray'), (option) =>
        @$('[name="subkast"]').append('<option value="' + option.value + '">' + option.option + '</option>')
      )

    onRender: =>
      FK.Utils.RenderHelpers.populate_select_getter(@, 'country', FK.Data.countries, 'en_name')
      @renderSubkastOptions()
      @refreshName @model
      @refreshSubkast @model
      @refreshLocation @model
      @refreshDescription @model
      @renderLocation()
