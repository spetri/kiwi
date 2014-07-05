class FK.Models.Comment extends Backbone.Model
  idAttribute: "_id"

  defaults:
    username: null
    upvotes: 0
    downvotes: 0
    have_i_upvoted: false
    have_i_downvoted: false
    message: ''
    event_id: null,
    parent_id: null,
    replies: []

  urlRoot: () =>
    '/comments'

  initialize: (attrs) =>
    #Backbone thing: when collection fetches from another url, models are
    #forced to have that url, undo that here
    #TODO: Report backbone bug?
    @url = Backbone.Model.prototype.url
    @replies = new FK.Collections.Comments(@get('replies'), {event_id: @get('event_id'), parent_id: @get('_id') })
    @on 'change:_id', @updateRepliesParent

  updateRepliesParent: (model, id) =>
    @replies.setParent(id)

  isReply: () =>
    !! @get('parent_id')

  setUsername: (username) =>
    @replies.username = username

  # upvoting
  upvotes: =>
    @get 'upvotes'

  userHasUpvoted: =>
    @get 'have_i_upvoted'

  toggleUserUpvoted: =>
    @set 'have_i_upvoted', not @userHasUpvoted()

  upvoteToggle: (e) =>
    return if @userHasUpvoted() 
    if @userHasDownvoted() then @changeDownvote(false)
    else @changeUpvote(true)
    @save {}

  # downvoting
  downvotes: =>
    @get 'downvotes'

  userHasDownvoted: =>
    @get 'have_i_downvoted'

  toggleUserDownvoted: =>
    @set 'have_i_downvoted', not @userHasDownvoted()

  downvoteToggle: (e) =>
    return if @userHasDownvoted()
    if @userHasUpvoted() then @changeUpvote(false)
    else @changeDownvote(true)
    @save {}

  changeUpvote: (bool) =>
    if bool then @set 'upvotes', @upvotes() + 1
    else @set 'upvotes', @upvotes() - 1
    @set 'have_i_upvoted', bool   

  changeDownvote: (bool) =>
    if bool then @set 'downvotes', @downvotes() + 1
    else @set 'downvotes', @downvotes() - 1
    @set 'have_i_downvoted', bool  

  deleteComment: () =>
    $.ajax
      url: @url()
      type: 'DELETE'
      success: (resp) =>
        @set resp

class FK.Collections.Comments extends Backbone.Collection
  model: FK.Models.Comment
  url: "/comments/"

  initialize: (models, options) =>
    @event_id = options.event_id
    @parent_id = options.parent_id

  fetchForEvent: () =>
    return if not @event_id
    @fetch
      url: "/api/events/#{@event_id}/comments"
      remove: false
      data:
        skip: 0

  setParent: (parent_id) =>
    @parent_id = parent_id

  setEvent: (event_id) =>
    @event_id = event_id
    @fetchForEvent()

  hasParent: =>
    return !! @parent_id

  comment: (message, username) =>
    params = { message: message, event_id: @event_id, username: username }
    params.parent_id = @parent_id
    @create params
