FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->
  @create = (options) ->
    @event = options.event
    @username = options.username

    @domLocation = options.domLocation

    @collection = @event.fetchComments()
    @collection.username = @username

    @layout =  new Comments.Layout
      collection: @collection
      el: @domLocation

    @commentViews = {}

    @commentsReplyView = new Comments.ReplyBox(collection: @collection)
    @commentsListView = new Comments.CommentsListView(collection: @collection)

    @commentsListView.on 'after:item:added', @registerCommentView

    @listenTo @commentsReplyView, 'click:add:comment', @comment

    @instance = new Comments.Controller
      collection: @collection
      layout: @layout

    @layout.on 'render', () =>
      if (@collection.knowsUser())
        @layout.comment_new.show(@commentsReplyView)
      @layout.comment_list.show(@commentsListView)

    #Put its root view into the dom
    @layout.render()

    return @instance

  @registerCommentView = (commentView) =>
    @commentViews[commentView.model.cid] = commentView
    replyViews = new Comments.CommentsListView collection: commentView.model.replies
    commentView.repliesRegion.show replyViews
    @listenTo commentView, 'click:reply', @openReply

  @comment = (args) =>
    view = args.view
    collection = args.collection
    collection.comment(view.commentValue())
    view.clearInput()

  @openReply = (args) =>
    model = args.model
    view = args.view
    collection = new FK.Collections.Comments([], { event_id: @event.get('_id'), parent_id: model.get('_id'), username: @username })
    replyBox = new Comments.ReplyBox({ collection: collection })

    @listenTo replyBox, 'click:add:comment', @comment
    view.replyBoxRegion.show replyBox

  class Comments.Controller extends Marionette.Controller
    initialize: (options) =>
      @layout = options.layout
      @collection = options.collection

  #Pulls together all the things
  class Comments.Layout extends Marionette.Layout
    template: FK.Template('comments')
    regions:
      comment_new: '#comment-new'
      comment_list: '#comment-list'

  #Renders the text box to create a new comment
  #Can be used either to create a top level comment or to reply
  class Comments.ReplyBox extends Marionette.ItemView
    template: FK.Template('comments_reply_box')
    class: 'col-md-12'

    events:
      'keyup textarea': 'writingComment'

    triggers:
      'click button': 'click:add:comment'

    clearInput: () =>
      @$('textarea').val('')
      @enableButton(0)

    commentValue: () =>
      @$('textarea').val()

    writingComment: (e) =>
      @enableButton(@$('textarea').val().length)

    enableButton: (numCharacters) =>
      if (numCharacters > 0)
        @$('button').removeClass('disabled')
      else
        @$('button').addClass('disabled')

    onRender: =>
      @enableButton(0)

  #Renders all the comment and all it's replies
  class Comments.CommentSingleView extends Marionette.Layout
    template: FK.Template('comment_single')
    className: 'comment'
    regions:
      'replyBoxRegion': '.replybox-region'
      'repliesRegion': '.replies-region'

    triggers:
      'click .reply': 'click:reply'

    initialize: =>
      @collection = @model.replies

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentSingleView
