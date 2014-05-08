class FK.Models.Comment extends Backbone.Model
  defaults:
    username: null
    upvotes: 0
    message: ''
    event_id: null,
    parent_id: null,
    replies_array: []

  urlRoot: () =>
    '/comments'

  initialize: (attrs) =>
    @replies = new FK.Collections.Comments(@get('replies_array'), {event_id: @get('event_id'), parent_id: @get('parent_id') })

class FK.Collections.Comments extends Backbone.Collection
  model: FK.Models.Comment
  url:
    "/comments/"

  initialize: (models, options) =>
    @event_id = options.event_id
    @parent_id = options.parent_id

  fetchForEvent: () =>
    @fetch
      url: "api/events/#{@event_id}/comments"
      remove: false
      data:
        skip: 0

  knowsUser: =>
    return @username.length > 0

  comment: (message) =>
    params = { message: message, event_id: @event_id, username: @username }
    params.parent_id = @parent_id
    @create params
