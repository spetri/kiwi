class FK.Models.Comment extends Backbone.Model
  defaults:
    username: null

  urlRoot: () =>
    '/comments'

  initialize: =>
    replies = @.get('replies')
    if (replies)
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

