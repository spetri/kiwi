class FK.Models.Event extends Backbone.GSModel
  idAttribute: "_id"
  defaults:
    country: 'US'
    name: ''
    user: ''
    #TODO: fix me - all events will start with the date that the file was parsed
    datetime: moment()
    thumbUrl: ''
    is_all_day: false
    time_format: ''
    tv_time: ''

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

      xhr.onload = (event) =>
        modelOnServer = JSON.parse event.target.response
        @set modelOnServer
        @trigger 'created', modelOnServer

      return xhr.send(formData)

    Backbone.sync(action, model, options)


  time_in_eastern: ->
    @.convert_moment_to_eastern moment(@.get('datetime'))

  convert_moment_to_eastern: (moment) ->
    moment.tz('America/New_York')
    @.time_from_moment(moment)

  time_from_moment: (moment) =>
    hours = if moment.hours() < 9 then "0#{moment.hours() + 1 }" else moment.hours() + 1
    minutes = if moment.minutes() < 10 then "0#{moment.minutes()}" else moment.minutes()
    "#{hours}:#{minutes}"


  getters:
    time: () ->
      if @.get('time_format') is 'recurring'
        @.get('local_time')

      if @.get('time_format') is 'tv_show'
        local_time_split = @.get('local_time').split(':')
        eastern_time = parseInt local_time_split[0]
        eastern_time = eastern_time - 12 if eastern_time > 11

        central_time = parseInt(local_time_split[0]) - 1
        central_time = central_time - 12 if central_time > 11
        central_time = 12 if central_time is 0

        return "#{eastern_time}/#{central_time}c"
      return @.time_from_moment(moment(@.get('datetime')))

    fk_datetime: () ->
      if @.get('time_format') is 'recurring'
        #console.log @.get('local_time')
        #time_split = @.get('local_time').split(':')
        time_split = @.get('time').split(':')
        return moment(@.get('datetime').format("YYYY-MM-DD")).add(hours: time_split[0], minutes: time_split[1])
      @.get('datetime')

  setters:
    datetime: (moment_val) ->
      moment_val = moment(moment_val) if typeof moment_val is "string"
      hour_offset = (- (moment_val.zone() / 60 )) * 100
      hour_offset = hour_offset + 1 # hours are zero-based for some silly reason
      if (hour_offset < 0)
        hour_offset = "GMT-#{hour_offset}"
      else
        hour_offset = "GMT+#{hour_offset}"

      @.set creation_timezone: hour_offset

      @.set local_time: @.time_from_moment(moment_val)

      moment_val.utc()



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
    sorted = @sortBy((ev) -> ev.get('fk_datetime')).reverse()
    new FK.Collections.EventBlockList(_.map(_.groupBy(sorted,(ev) ->
      moment(ev.get('fk_datetime')).format("YYYY-MM-DD")
    ), (blocks, date) ->
      events: new FK.Collections.EventList(blocks), date: date
    ))


class FK.Collections.EventBlockList extends Backbone.Collection
  model: FK.Models.EventBlock
