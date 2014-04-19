FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->
  @create = (options) ->
    @event = options.event
    @domLocation = options.domLocation
    @collection = @event.fetchComments()
    @layout =  new Comments.Layout
      collection: @collection

      username: App.request('currentUser').get('username')
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

    value: () =>
      {}

  #Pulles together all the things
  class Comments.Layout extends Marionette.Layout
    template: FK.Template('comments')
    regions:
      comment_new: '#comment-new'
      comment_list: '#comment-list'

    initialize: (options) =>
      @username = options.username
      @model = new FK.Models.Comment(username: @username, event_id: options.event.get('_id'))
      @commentNewView = new Comments.CommentNewView(model: @model)
      @commentsListView = new Comments.CommentsListView(collection: @collection)

    onRender: =>
      @comment_new.show(@commentNewView)
      @comment_list.show(@commentsListView)

  #Renders the text box to create a new comment
  #Can be used either to create a top level comment or to reply
  class Comments.CommentNewView extends Marionette.ItemView
    template: FK.Template('comments_new')
    class: 'col-md-12'
    events: 
      'click button': 'createClicked'

    createClicked: (e) =>
      e.preventDefault()
      @model.save(message: @$('textarea').val())

  #Renders all the comment and all it's replies
  class Comments.CommentView extends Marionette.CompositeView
    template: FK.Template('comment_single')

    initialize: =>
      @collection = @model.replies

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentView

