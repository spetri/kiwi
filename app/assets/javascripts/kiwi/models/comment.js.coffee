class FK.Models.Comment extends Backbone.Model
  idAttribute: "_id"

  defaults:
    username: null
    upvotes: 0
    have_i_upvoted: false
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
    @url = Backbone.Model.prototype.url
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

  initialUpvote: =>
    @set 'upvotes', 1
    @set 'have_i_upvoted', true

  toggleUserUpvoted: =>
    @set 'have_i_upvoted', not @userHasUpvoted()

  upvoteToggle: (e) =>
    if @userHasUpvoted()
      @set 'upvotes', @upvotes() - 1
    else
      @set 'upvotes', @upvotes() + 1
    @toggleUserUpvoted() 
    @save null,
      success: (data) ->
        console.log data
        # TODO: access data attributes
        if @$('.up-vote i.fa-arrow-down').hasClass('downvote-marked')
           @$('.up-vote i.fa-arrow-down').removeClass('downvote-marked')
        @$('.up-vote i.fa-arrow-up').addClass('upvote-marked')

  # downvoting
  downvoteToggle: (e) =>
    if !@userHasUpvoted()
      @set 'upvotes', @upvotes() + 1
    else
      @set 'upvotes', @upvotes() - 1
    
    @save null,
      success: ->
        if @$('.up-vote i.fa-arrow-up').hasClass('upvote-marked')
          @$('.up-vote i.fa-arrow-up').removeClass('upvote-marked')
        @$('.up-vote i.fa-arrow-down').addClass('downvote-marked')

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
