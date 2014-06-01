FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->

  @create = (options) ->
    @instance = new Comments.Controller options
    @instance.fetch()
    return @instance

  class Comments.Controller extends Marionette.Controller
    initialize: (options) =>
      @layout = new Comments.Layout
        el: options.domLocation

      @username = options.username

      @collection = options.event.comments
      @collection.username = options.username

      @commentViews = {}
      @commentsListView = new Comments.CommentsListView(collection: @collection)
      @commentsListView.on 'before:item:added', @registerCommentView
      @commentsListView.on 'after:item:added', @showReplies

      @layout.on 'render', () =>
        @commentBox = @openReply(@layout.commentNewRegion, @collection)
        @layout.commentListRegion.show(@commentsListView)

      #Put its root view into the dom
      @layout.render()

    fetch: () =>
      @collection.fetchForEvent()

    registerCommentView: (commentView) =>
      @commentViews[commentView.model.cid] = commentView
      commentView.model.setUsername(@username)
      @listenTo commentView, 'click:reply', @openReplyFromView

    showReplies: (commentView) =>
      replyViews = new Comments.CommentsListView collection: commentView.model.replies
      @listenTo replyViews, 'before:item:added', @registerCommentView
      @listenTo replyViews, 'after:item:added', @showReplies
      commentView.repliesRegion.show replyViews

    openReplyFromView: (args) =>
      @openReply(args.view.replyBoxRegion, args.model.replies)

    openReply: (region, collection) =>
      return if not collection.knowsUser()
      replyBox = new Comments.ReplyBox({ collection: collection })
      @listenTo replyBox, 'click:add:comment', @comment
      region.show replyBox
      replyBox

    comment: (args) =>
      view = args.view
      collection = args.collection
      collection.comment(view.commentValue())
      view.clearInput()

    onClose: () =>
      @layout.close()

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
      if @collection.hasParent()
        @close()
      else
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

    onShow: =>
      if (@collection.hasParent())
        @$('textarea').focus()

  #Renders all the comment and all it's replies
  class Comments.CommentSingleView extends Marionette.Layout
    template: FK.Template('comment_single')
    className: 'comment'
    regions:
      'replyBoxRegion': '.nested-comments:first > .replybox-region'
      'repliesRegion': '.nested-comments:first > .replies-region'

    templateHelpers: () =>
      return {
        message_marked: marked(@model.get('message'))
      }

    events:
      'click .fa-arrow-up': 'upvote'

    triggers:
      'click .reply': 'click:reply'

    initialize: =>
      @collection = @model.replies

    upvote: =>
      @model.upvoteToggle()

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

    onShow: () =>
      if not @collection.knowsUser()
        @$('.reply').tooltip(
          title: 'Login to reply.'
        )

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentSingleView
    className: 'comment-list'
