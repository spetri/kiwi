FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  class DatePicker.DatePickerView extends Marionette.ItemView
    template: FK.Template 'date_picker'
    events:
      'change input,select': 'pickerChanged'

    modelEvents: 
      'change:datetime': 'updateStatus'

    pickerChanged: (e) =>
      @updateModel()

    updateModel: =>
      date = @$('input[name=date]').val()
      time = "#{@$('select[name=hours]').val()}:#{@$('select[name=minutes]').val()} #{@$('select[name=ampm]').val()}"
      val = moment("#{date} #{time}")
      @model.set('datetime', val.utc())
    
    initialize: (opts) ->
      @controller = opts.controller

    onRender: () ->
      @$('input[name=date]').datepicker()

    updateStatus: => 
      @$('.status').text(moment(@model.get('datetime'))._d.toString())
