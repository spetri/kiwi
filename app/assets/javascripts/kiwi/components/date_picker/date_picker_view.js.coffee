FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  class DatePicker.DatePickerView extends Marionette.ItemView
    className: 'date_picker'
    template: FK.Template 'date_picker'

    templateHelpers: =>
      local_hour: => @model.get('local_hour')
      local_minute: => @model.get('local_minute')
      local_ampm: => @model.get('local_ampm')
      local_date: => @model.get('fk_datetime').format('MM/DD/YYYY')

    events:
      'change [name="date"],[name="hours"],[name="minutes"],[name="ampm"]': 'updateDateTime'
      'change [name="time_format"]': 'updateTimeFormat'
      'click .datepicker .day': 'updateDateTime'

    updateDateTime: =>
      @datepicker.datepicker('hide')
      date = @$('input[name=date]').val()
      time = "#{@$('select[name=hours]').val()}:#{@$('select[name=minutes]').val()} #{@$('select[name=ampm]').val()}"
      @model.moveToDateTime(date, time) if date and time

    updateTimeFormat: =>
      time_format = @$('input[name=time_format]:checked').val()
      @model.set('time_format', time_format)
      @updateDateTime()

    updateAllDay: =>
      @updateDateTime()
      is_all_day = @$('input[name=is_all_day]').prop('checked')
      @model.set('is_all_day', is_all_day)
      @toggleAllDay(is_all_day)

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
      @toggleAllDay(@model.isAllDay())

    toggleAllDay: (is_all_day) =>
      if is_all_day
        @$el.addClass('all_day')
      else
        @$el.removeClass('all_day')

    refreshTime: =>
      return unless @model.has('datetime')
      @refreshTimeDisplay()

    refreshTimeDisplay: =>
      return unless @model.has('datetime')
      @$('.time-display-value').text(@model.get('time'))
      @$('.status').text(@model.get('datetime').format('ddd MMM DD YYYY HH:mm:ss'))

    refreshTimeFormat: =>
      @$('[name="time_format"]').not('[value="' + @model.get('time_format') + '"]').removeAttr('checked', 'checked')
      @$('[name="time_format"][value="' + @model.get('time_format') + '"]').attr('checked', 'checked')
      @refreshTimeDisplay()
      @refreshTimezone()

    refreshTimezone: =>
      tz = jstz.determine()
      name = if @model.get('time_format') is 'tv_show' then 'America/New York' else tz.name()
      @$('.timezone-display').text("(#{name.replace('_', ' ')})")

    onRender: () =>
      @refreshAllDay()
      @refreshTime()
      @refreshTimeFormat()
      @datepicker = @$('input[name="date"]').datepicker()
      @updateDateTime()
