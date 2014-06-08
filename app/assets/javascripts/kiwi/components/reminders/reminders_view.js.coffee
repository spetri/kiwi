FK.App.module "Reminders", (Reminders, App, Backbone, Marionette, $, _) ->

  @create = (options) =>
    instance = new Reminders.Controller options
    instance.show()
    instance

  class Reminders.Controller extends Marionette.Controller
    initialize: (options) =>
      @event = options.event
      @region = new Reminders.RemindersRegion
        attachTo: options.attachTo
        el: options.container

    show: () =>
      @region.show new Reminders.RemindersView

  class Reminders.RemindersRegion extends Marionette.Region
    initialize: (options) =>
      @attachTo = options.attachTo

    onShow: (view) =>
      @el.css('position', 'absolute')
      @el.css('z-index', 2000)
      @el.css('left', '630px')
      @el.css('top', '105px')

  class Reminders.RemindersView extends Marionette.ItemView
    template: FK.Template('event_reminders')
    className: 'event-reminders-super-container'
