class FK.Models.Comment extends Backbone.Model
  defaults:
    username: null
    upvotes: 0
    message: ''
    replies: []

  urlRoot: () =>
    '/comments'

  getRepliesCollection: () =>
    @replies

  initialize: =>
    replies = @.get('replies')
    @replies = new FK.Collections.Comments(replies)

class FK.Collections.Comments extends Backbone.Collection
  model: FK.Models.Comment
  url:
    "/comments/"

  fetchForEvent: (event) =>
    @fetch
      url: "api/events/#{event.get('_id')}/comments"
      remove: false
      data:
        skip: 0
    @event = event

  comment: (message) =>
    @create( message: message, event_id: @event.get('_id') )
