FK.App.module "Reminders", (Reminders, App, Backbone, Marionette, $, _) ->

  @create = (options) =>
    instance = new Reminders.Controller options
    instance

  class Reminders.Controller extends Marionette.Controller
    initialize: (options) =>
      @event = options.event
      @user = App.request('currentUser')

      @reminders = new FK.Collections.Reminders
      @reminders.fetchForUserAndEvent(@user, @event)

      @region = new Reminders.RemindersRegion
        attachTo: options.attachTo
        el: options.container

      @view = new Reminders.RemindersView

      @listenTo @view, 'click:set-reminder', @setReminder
      @listenTo @view, 'click:cancel', @close
      @listenTo @reminders, 'fetched', @show

    setReminder: () =>
      times = @view.getTimes()

      @reminders.addReminders(@user, @event, times)
      @reminders.removeReminders(@user, @event, _.difference(['15m', '1h', '4h', '1d' ], times))

      @region.close()

    show: () =>
      @region.show @view
      @view.setTimes(@reminders.times())

    onClose: () =>
      @region.close()

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

    triggers:
      'click [data-action="set-reminder"]': 'click:set-reminder'
      'click [data-action="cancel"]': 'click:cancel'

    getTimes: () =>
      $.map($('input:checked'), (box, i) =>
        $(box).data('time')
      )

    setTimes: (times) =>
      _.each(times, (time) =>
        $('[data-time="' + time + '"]').prop('checked', true)
      )
