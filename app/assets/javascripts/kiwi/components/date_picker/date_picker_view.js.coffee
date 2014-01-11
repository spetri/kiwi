FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  class DatePicker.DatePickerView extends Marionette.ItemView
    template: FK.Template 'date_picker'
    events:
      'change input,select': 'pickerChanged'

    modelEvents:
      'change:is_all_day': 'updateTimeStatus'
      'change:datetime':   'updateTime'
      'change:time_format':'updateTimeFormat'

    pickerChanged: (e) =>
      @updateModel()

    updateModel: =>
      is_all_day  = @$('input[name=is_all_day]:checked').val() is '1'
      time_format = @$('input[name=time_format]:checked').val()
      date = @$('input[name=date]').val()
      time = "#{@$('select[name=hours]').val()}:#{@$('select[name=minutes]').val()} #{@$('select[name=ampm]').val()}"
      @model.set(
        datetime: moment("#{date} #{time}"),
        is_all_day: is_all_day,
        time_format: time_format)

    updateTimeStatus: =>
      selector = @$('input[name=time_format],select[name=hours],select[name=minutes],select[name=ampm],select[name=time_type]')
      if @model.is_all_day()
        selector.attr('disabled','disabled')
        @$('.timedisplay').hide()
        @$('[name="is_all_day"]').attr('checked', 'checked')
      else
        selector.removeAttr('disabled')
        @$('.timedisplay').show()
        @$('[name="is_all_day"]').removeAttr('checked')
        @updateTimeFormat()

    updateTime: =>
      @updateTimeDisplay()
      @$('[name="hours"]').val @model.get('local_hour')
      @$('[name="minutes"]').val @model.get('local_minute')
      @$('[name="ampm"]').val @model.get('local_ampm')
      @$('input[name="date"]').val(this.model.get('datetime').format('MM/DD/YYYY')) if @model.get('datetime')

    updateTimeDisplay: =>
      @$('.time-display-value').text(@model.get('time'))
      @$('.status').text(@model.get('datetime').format('ddd MMM DD YYYY HH:mm:ss')) if @model.get('datetime')

    updateTimeFormat: =>
      @$('[name="time_format"]').not('[value="' + @model.get('time_format') + '"]').removeAttr('checked', 'checked')
      @$('[name="time_format"][value="' + @model.get('time_format') + '"]').attr('checked', 'checked')
      @updateTimeDisplay()

    onRender: () =>
      date = @model.get('datetime')
      @$('input[name="date"]').datepicker()
      @updateTimeStatus()
      @updateTimeFormat()
      @updateTime()
