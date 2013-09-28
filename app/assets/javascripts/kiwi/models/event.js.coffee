class FK.Models.Event extends Backbone.Model
  idAttribute: "_id"
  defaults:
    country: 'US'
    name: ''
    user: ''
    #TODO: fix me - all events will start with the date that the file was parsed
    datetime: new Date()
    thumbUrl: ''

  url: =>
    if @isNew() then @collection.url else @collection.url + '/' + @id

  sync: (action, model, options) =>
    methodMap =
      'create': 'POST'
      'update': 'PUT'


    if action == "create" or action == "update"
      httpMethod = methodMap[action]
      
      xhr = new XMLHttpRequest()
      xhr.open(httpMethod, this.url(), true)
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      
      formData = new FormData()

      _.each model.toJSON(), (v, k) ->
        formData.append(k, v)

      return xhr.send(formData)

    Backbone.sync(action, model, options)

class FK.Models.EventBlock extends Backbone.Model


class FK.Collections.EventList extends Backbone.Collection
  model: FK.Models.Event
  url:
    "/events/"

  topRanked: =>
    #TODO: fix me
    @first()

  mostDiscussed: =>
    #TODO: fix me
    @last()

  asBlocks: =>
    sorted = @sortBy((ev) -> ev.get('datetime')).reverse()
    new FK.Collections.EventBlockList(_.map(_.groupBy(sorted,(ev) ->
      moment(ev.get('datetime')).format("YYYY-MM-DD")
    ), (blocks, date) ->
      events: new FK.Collections.EventList(blocks), date: date
    ))


class FK.Collections.EventBlockList extends Backbone.Collection
  model: FK.Models.EventBlock
