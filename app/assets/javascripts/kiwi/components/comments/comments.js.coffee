FK.App.module "Comments", (Comments, App, Backbone, Marionette, $, _) ->
  @create = (options) ->
    @event = options.event
    @domLocation = options.domLocation

    @collection = new Comments.CommentCollection([{
      body: 'This looks like it will be an awesome event! He heard something loud and clearly out of the ordinary, but somewhat familiar. So he immediately reacted by a reflexive look up, then paused to determine the orgin and legitimacy of the familiar sound. He then determined that the chances of one of his kind attending this musical precession was highly unlikely, and continued on with what he was doing. He also would like to add, that your remark was very insulting, and suggest that you think next time before accusing an imaginary elephant of stupidity.',
      username: 'Kirk',
      upvotes: 10,
      depth:0,
      replies: [
        {
          body: 'No, I think that this will kinda suck, I\'m just a Doctor',
          username: 'McCoy'
          upvotes: 33,
          depth: 1,
          replies: [
            {
              body: 'how did i even get here',
              username: 'Worf',
              upvotes: 0,
              depth: 2,
            }
          ]
        }
      ]
    },{
      body: 'Engage!',
      username: 'Picard',
      upvotes: 100,
      depth: 0
    }])

    @layout =  new Comments.Layout
      collection: @collection

      username: App.request('currentUser').get('username')
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
      @model = new Comments.ViewModel(username: @username)
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

  #Renders all the comment and all it's replies
  class Comments.CommentView extends Marionette.CompositeView
    template: FK.Template('comment_single')

    initialize: =>
      @collection = @model.replies

    appendHtml: (collectionView, itemView) =>
      collectionView.$("div.comment").append(itemView.el)

  class Comments.CommentsListView extends Marionette.CollectionView
    itemView: Comments.CommentView

  class Comments.ViewModel extends Backbone.Model
    defaults:
      username: null

    initialize: =>
      replies = @.get('replies')
      if (replies)
        @replies = new Comments.CommentCollection(replies);
        @.unset("nodes");

  class Comments.CommentCollection extends Backbone.Collection
    model: Comments.ViewModel
