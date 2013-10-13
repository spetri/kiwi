FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  class DatePicker.DatePickerView extends Marionette.ItemView
    template: FK.Template 'date_picker'

    initialize: (opts) ->
      @controller = opts.controller

    onRender: () ->
      @$('input[name=date]').datepicker()
