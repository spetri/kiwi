FK.App.module "Events.EventList", (EventList, App, Backbone, Marionette, $, _) ->

  class EventList.EventBlock extends Backbone.Marionette.CompositeView
    template: FK.Template('event_block')
    className: 'event-block'
    itemViewContainer: '.events'
    itemView: EventList.EventCollapsed
    itemViewEventPrefix: 'event'
    
    appendHtml: (collectionView, itemView, index) =>
      collectionView = collectionView.$(@itemViewContainer)
      return collectionView.prepend(itemView.el) if index is 0
      atIndex = collectionView.children().eq(index)
      return atIndex.before(itemView.el) if atIndex.length
      return collectionView.append(itemView.el)

    templateHelpers: () =>
      isToday: () => @model.isToday()
    events:
      'click .btn': 'loadMore'

    loadMore: (e) =>
      e.preventDefault()
      @model.increaseLimit(3)

    modelEvents:
      'change:more_events_available': 'refreshMoreEventsDisabled'

    refreshMoreEventsDisabled: (block, moreEventsAvailable) =>
      if (moreEventsAvailable)
        @$('.btn').removeClass('hide')
      else
        @$('.btn').addClass('hide')

    onRender: () =>
      @refreshMoreEventsDisabled(@model, @model.get('more_events_available'))
