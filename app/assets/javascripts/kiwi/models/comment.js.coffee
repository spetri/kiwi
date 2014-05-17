class FK.Models.Comment extends Backbone.Model
  idAttribute: '_id'
  defaults:
    username: null
    upvotes: 0
    message: ''
    event_id: null,
    parent_id: null,
    replies: []

  urlRoot: () =>
    '/comments'

  initialize: (attrs) =>
    @replies = new FK.Collections.Comments(@get('replies'), {event_id: @get('event_id'), parent_id: @get('_id') })
    @url = Backbone.Model.prototype.url
    @on 'change:_id', @updateRepliesParent

  updateRepliesParent: (model, id) =>
    @replies.setParent(id)

  isReply: () =>
    !! @get('parent_id')

  setUsername: (username) =>
    @replies.username = username

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
    return @username and @username.length > 0

  setParent: (parent_id) =>
    @parent_id = parent_id

  hasParent: =>
    return !! @parent_id

  comment: (message) =>
    params = { message: message, event_id: @event_id, username: @username }
    params.parent_id = @parent_id
    @create params
