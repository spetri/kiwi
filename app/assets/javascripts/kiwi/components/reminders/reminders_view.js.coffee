FK.App.module "Reminders", (Reminders, App, Backbone, Marionette, $, _) ->

  @instance = null

  @create = (options) =>
    @instance.close() if @instance
    @instance = new Reminders.DropdownController options
    @instance

  class Reminders.DropdownController extends Marionette.Controller
    initialize: (options) =>
      @event = options.event
      @user = App.request('currentUser')

      @reminders = @event.reminders

      @region = new Marionette.Region
        el: options.container

      @view = new Reminders.RemindersView

      @listenTo @view, 'click:set-reminder', @setReminder
      @listenTo @view, 'click:cancel', @close
      @listenTo App.vent, 'app:click', @close

      @show()

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

  class Reminders.RemindersView extends Marionette.ItemView
    template: FK.Template('event_reminders')
    className: 'event-reminders-super-container'

    triggers:
      'click [data-action="set-reminder"]': 'click:set-reminder'
      'click [data-action="cancel"]': 'click:cancel'

    templateHelpers: {
      loggedIn: () =>
        user = App.request('currentUser')
        user.get('logged_in')
    }

    events:
      'click': 'stopPropagate'

    stopPropagate: (e) =>
      e.stopPropagation()

    getTimes: () =>
      $.map($('input:checked'), (box, i) =>
        $(box).data('time')
      )

    setTimes: (times) =>
      if times.length > 0
        _.each(times, (time) =>
          $('[data-time="' + time + '"]').prop('checked', true)
        )
      else
        $('[data-time="1h"]').prop('checked', true)
