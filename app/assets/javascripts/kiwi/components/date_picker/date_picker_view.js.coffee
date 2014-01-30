FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  class DatePicker.DatePickerView extends Marionette.ItemView
    template: FK.Template 'date_picker'
    events:
      'change [name="date"],[name="hours"],[name="minutes"],[name="ampm"]': 'updateDateTime'
      'change [name="time_format"]': 'updateTimeFormat'
      'change [name="is_all_day"]': 'updateAllDay'

    updateDateTime: =>
      date = @$('input[name=date]').val()
      time = "#{@$('select[name=hours]').val()}:#{@$('select[name=minutes]').val()} #{@$('select[name=ampm]').val()}"
      @model.set('datetime', moment("#{date} #{time}")) if date and time

    updateTimeFormat: =>
      time_format = @$('input[name=time_format]:checked').val()
      @model.set('time_format', time_format)

    updateAllDay: =>
      is_all_day = @$('input[name=is_all_day]').prop('checked')
      @model.set('is_all_day', is_all_day)

    modelEvents:
      'change:is_all_day': 'refreshAllDay'
      'change:datetime':   'refreshTime'
      'change:time_format':'refreshTimeFormat'

    refreshAllDay: =>
      selector = @$('input[name=time_format],select[name=hours],select[name=minutes],select[name=ampm],select[name=time_type]')
      if @model.isAllDay()
        selector.attr('disabled','disabled')
        @$('.timedisplay').hide()
        @$('[name="is_all_day"]').attr('checked', 'checked')
      else
        selector.removeAttr('disabled')
        @$('.timedisplay').show()
        @$('[name="is_all_day"]').removeAttr('checked')
        @updateTimeFormat()

    refreshTime: =>
      return if not @model.has('datetime')
      @refreshTimeDisplay()
      @$('[name="hours"]').val @model.get('local_hour')
      @$('[name="minutes"]').val @model.get('local_minute')
      @$('[name="ampm"]').val @model.get('local_ampm')
      @$('input[name="date"]').val(this.model.get('fk_datetime').format('MM/DD/YYYY'))

    refreshTimeDisplay: =>
      return if not @model.has('datetime')
      @$('.time-display-value').text(@model.get('time'))
      @$('.status').text(@model.get('datetime').format('ddd MMM DD YYYY HH:mm:ss'))

    refreshTimeFormat: =>
      @$('[name="time_format"]').not('[value="' + @model.get('time_format') + '"]').removeAttr('checked', 'checked')
      @$('[name="time_format"][value="' + @model.get('time_format') + '"]').attr('checked', 'checked')
      @refreshTimeDisplay()

    onRender: () =>
      date = @model.get('datetime')
      @$('input[name="date"]').datepicker()
      @refreshAllDay()
      @refreshTime()
      @refreshTimeFormat()
