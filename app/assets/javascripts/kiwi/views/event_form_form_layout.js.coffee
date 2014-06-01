FK.App.module "Events.EventForm", (EventForm, App, Backbone, Marionette, $, _) ->
  class EventForm.FormLayout extends Backbone.Marionette.Layout
    className: "event-form container"
    template: FK.Template('event_form')

    regions:
      'saveContainerRegion': '.save-container'

    events:
      'change input[name=location_type]': 'renderLocation'
      'keyup input[name=name]': 'refreshNameCounter'

    renderLocation: (e) =>
      if @$el.find('input[name=location_type]:checked').val() is "international"
        @$el.find('select[name=country]').attr('disabled','disabled')
      else
        @$el.find('select[name=country]').removeAttr('disabled')

    refreshNameCounter: (e) =>
      input = @$el.find('input[name=name]')
      remaining = @model.remainder_count - input.val().length
      input.next('span').text "#{remaining} characters remaining"
      if remaining < 20
        input.next('span').css("color", "#8a6d3b")
      else
        input.next('span').css("color", "black")


    modelEvents:
      'change:name': 'refreshName'
      'change:subkast': 'refreshSubkast'
      'change:location_type': 'refreshLocation'
      'change:country': 'refreshLocation'
      'change:description': 'refreshDescription'
      'change:is_all_day': 'refreshAllDay'
      'invalid': 'refreshErrors'
      'start:save': 'clearErrors'

    refreshName: (event) ->
      @$('#name').val event.get('name')

    refreshSubkast: (event) ->
      @$('[name="subkast"]').val(event.get('subkast'))

    refreshLocation: (event) ->
      @$('[name="location_type"][value="' + event.get('location_type') + '"]').attr('checked', 'checked')
      @$('[name="country"] [value="' + event.get('country') + '"]').attr('selected', 'selected')

    refreshDescription: (event) ->
      @$('[name="description"]').val(event.get('description'))

    refreshErrors: (model) ->
      _.each(model.groupedErrors(), (messages, field) =>
        @$('[data-field="' + field + '"].error').text(messages.join('<br />'))
      )
      @toFirstError()

    toFirstError: () ->
      firstError = _.find( @$('[data-field].error'), (elem) =>
        $(elem).text().length > 0
      )

      $(document).scrollTop($(firstError).offset().top - 120)

    refreshAllDay: (model) =>
      if @model.get('is_all_day')
        @$('.event_form_date').addClass('is_all_day')
      else
        @$('.event_form_date').removeClass('is_all_day')

    clearErrors: () ->
      @$('[data-field].error').each((i, elem) =>
        $(elem).text('')
      )

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
      @refreshAllDay @model
      @renderLocation()
