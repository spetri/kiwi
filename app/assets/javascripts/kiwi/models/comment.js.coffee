class FK.Models.Comment extends Backbone.Model
  defaults:
    _id: ''
    username: null
    upvotes: 0
    message: ''
    event_id: null,
    parent_id: null,
    replies: []

  urlRoot: () =>
    '/comments'

  initialize: (attrs) =>
    @replies = new FK.Collections.Comments(@get('replies'), {event_id: @get('event_id'), parent_id: @get('_id'), username: @get('username') })

  isReply: () =>
    !! @get('parent_id')

class FK.Collections.Comments extends Backbone.Collection
  model: FK.Models.Comment
  url:
    "/comments/"

  initialize: (models, options) =>
    @event_id = options.event_id
    @parent_id = options.parent_id
    @username = options.username

  fetchForEvent: () =>
    @fetch
      url: "api/events/#{@event_id}/comments"
      remove: false
      data:
        skip: 0

  knowsUser: =>
    return @username.length > 0

  hasParent: =>
    return !! @parent_id

  comment: (message) =>
    params = { message: message, event_id: @event_id, username: @username }
    params.parent_id = @parent_id
    @create params
