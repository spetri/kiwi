FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->

  @create = (options) ->
    return new Comments.Controller options

  class Comments.Controller extends Marionette.Controller
    initialize: (options) =>
      @layout = new Comments.Layout
        el: options.domLocation

      @collection = options.event.fetchComments()
      @collection.username = options.username

      @commentViews = {}
      @commentsListView = new Comments.CommentsListView(collection: @collection)
      @commentsListView.on 'after:item:added', @registerCommentView

      @layout.on 'render', () =>
        if (@collection.knowsUser())
          @openReply(@layout.commentNewRegion, @collection)
        @layout.commentListRegion.show(@commentsListView)

      #Put its root view into the dom
      @layout.render()

    registerCommentView: (commentView) =>
      @commentViews[commentView.model.cid] = commentView
      replyViews = new Comments.CommentsListView collection: commentView.model.replies
      @listenTo commentView, 'click:reply', @openReplyFromView
      @listenTo replyViews, 'after:item:added', @registerCommentView
      commentView.repliesRegion.show replyViews

    openReplyFromView: (args) =>
      @openReply(args.view.replyBoxRegion, args.model.replies)

    openReply: (region, collection) =>
      replyBox = new Comments.ReplyBox({ collection: collection })
      @listenTo replyBox, 'click:add:comment', @comment
      region.show replyBox

    comment: (args) =>
      view = args.view
      collection = args.collection
      collection.comment(view.commentValue())
      view.clearInput()

  #Pulls together all the things
  class Comments.Layout extends Marionette.Layout
    template: FK.Template('comments')
    regions:
      commentNewRegion: '#comment-new'
      commentListRegion: '#comment-list'

  #Renders the text box to create a new comment
  #Can be used either to create a top level comment or to reply
  class Comments.ReplyBox extends Marionette.ItemView
    template: FK.Template('comments_reply_box')
    className: 'reply-box'

    templateHelpers: () =>
      return cancelButton: @collection.hasParent()

    events:
      'keyup textarea': 'writingComment'
      'click [data-action="cancel"]': 'close'

    triggers:
      'click [data-action="comment"]': 'click:add:comment'

    clearInput: () =>
      @$('textarea').val('')
      @enableButton(0)

    commentValue: () =>
      @$('textarea').val()

    writingComment: (e) =>
      @enableButton(@$('textarea').val().length)

    enableButton: (numCharacters) =>
      if (numCharacters > 0)
        @$('[data-action="comment"]').removeClass('disabled')
      else
        @$('[data-action="comment"]').addClass('disabled')

    onRender: =>
      @enableButton(0)

  #Renders all the comment and all it's replies
  class Comments.CommentSingleView extends Marionette.Layout
    template: FK.Template('comment_single')
    className: 'comment'
    regions:
      'replyBoxRegion': '.nested-comments:first > .replybox-region'
      'repliesRegion': '.nested-comments:first > .replies-region'

    triggers:
      'click .reply': 'click:reply'

    initialize: =>
      @collection = @model.replies

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentSingleView
    className: 'comment-list'
