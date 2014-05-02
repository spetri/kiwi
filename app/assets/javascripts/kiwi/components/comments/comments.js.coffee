FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->
  @create = (options) ->
    @event = options.event
    @username = options.username
    @domLocation = options.domLocation
    @collection = @event.fetchComments()
    @collection.username = @username
    @layout =  new Comments.Layout
      collection: @collection
      event: @event
      el: @domLocation

    @instance = new Comments.Controller
      collection: @collection
      layout: @layout

    #Put its root view into the dom
    @layout.render()

    return @instance

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

    initialize: (options) =>
      @model = new FK.Models.Comment(event_id: options.event.get('_id'))
      @commentsReplyView = new Comments.ReplyBox(collection: @collection, is_root: true)
      @commentsListView = new Comments.CommentsListView(collection: @collection)

    onRender: =>
      if (@collection.knowsUser())
        @comment_new.show(@commentsReplyView)
      @comment_list.show(@commentsListView)

  #Renders the text box to create a new comment
  #Can be used either to create a top level comment or to reply
  class Comments.ReplyBox extends Marionette.ItemView

    initialize: (options) =>
      @is_root = false
      if options.is_root
        @is_root = options.is_root

    template: FK.Template('comments_reply_box')
    class: 'col-md-12'

    events:
      'click button': 'createClicked'
      'keyup textarea': 'writingComment'

    createClicked: (e) =>
      e.preventDefault()
      @collection.comment(@$('textarea').val())
      @$('textarea').val('')
      @enableButton(0)

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
  class Comments.CommentSingleView extends Marionette.CompositeView
    template: FK.Template('comment_single')
    className: 'comment'
    events:
      'click .reply': 'replyClicked'

    replyClicked: (e) =>
      e.preventDefault()
      model = new FK.Models.Comment(parent_id: @model.get('_id'))
      reply_box = new Comments.ReplyBox(model: model,collection: @model.getRepliesCollection())
      @$('.replybox').html(reply_box.render().el)

    initialize: =>
      @collection = @model.replies

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentSingleView
