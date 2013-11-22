FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  Instance = null

  @addFinalizer () ->
    Instance.close()

  @create = (domLocation, event) ->
    newInstance = new DatePicker.DatePickerController
      model: event
    regionManager = new Marionette.RegionManager()
    region = regionManager.addRegion("instance", domLocation)
    region.show new DatePicker.DatePickerView
      model: event

    newInstance.on 'close', () =>
      regionManager.close()

    Instance = newInstance
    return newInstance


  class DatePicker.DatePickerController extends Marionette.Controller
    initialize: (options) =>
      @model = options.model

    value: () =>
      # I'm a good citizen, i only return what I partied on
      {
        datetime: @model.get('datetime')
        time_format: @model.get('time_format')
        local_time: @model.get('local_time')
        is_all_day: @model.get('is_all_day')
      }
