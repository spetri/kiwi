FK.App.module "DatePicker", (DatePicker, App, Backbone, Marionette, $, _) ->
  Instance = null

  @addFinalizer () ->
    Instance.close()

  @create = (domLocation) ->
    newInstance = new DatePicker.DatePickerController()
    regionManager = new Marionette.RegionManager()
    region = regionManager.addRegion("instance", domLocation)
    region.show new DatePicker.DatePickerView
      controller: newInstance
      model: newInstance.model

    newInstance.on 'close', () =>
      regionManager.close()

    Instance = newInstance
    return newInstance


  class DatePicker.DatePickerController extends Marionette.Controller
    initialize: () ->
      @model = new Backbone.Model()

    value: () =>
      Instance.model.toJSON()
