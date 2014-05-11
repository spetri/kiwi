describe 'comments', ->
  describe 'comment models', ->
    describe 'without a parent', ->
      beforeEach ->
        @comments = new FK.Collections.Comments([], event_id: '1234' )
        @comments.username = 'pizza'

      describe 'when writing a comment', ->
        beforeEach ->
          @xhr = sinon.useFakeXMLHttpRequest()
          @requests = []

          @xhr.onCreate = (xhr) =>
            @requests.push xhr

          @comments.comment('Warbling in the dark')

        afterEach ->
          @xhr.restore()

        it 'should be able to comment', ->
          expect(@comments.length).toBe(1)

        it 'should have the correct body on the comment', ->
          expect(@comments.first().get('message')).toBe('Warbling in the dark')

        it 'should have the correct username', ->
          expect(@comments.first().get('username')).toBe('pizza')

        it 'should not be a reply', ->
          expect(@comments.first().isReply()).toBeFalsy()

      it 'should know that it does not have a parent', ->
        expect(@comments.hasParent()).toBeFalsy()

      it 'should know that it has a user', ->
        expect(@comments.knowsUser()).toBeTruthy()

    describe 'with a parent', ->
      beforeEach ->
        @comments = new FK.Collections.Comments([], event_id: '1234', username: 'pizza', parent_id: 1 )

      describe 'when writing a comment', ->
        beforeEach ->
          @xhr = sinon.useFakeXMLHttpRequest()
          @requests = []

          @xhr.onCreate = (xhr) =>
            @requests.push xhr

          @comments.comment('Warbling in the dark')

          @requests[0].respond(200, { "Content-Type: application/json" }, JSON.stringify({ message: 'Warbling in the dark', username: 'pizza', parent_id: 1 }))

        afterEach ->
          @xhr.restore()

        it 'should create a comment as a reply', ->
          expect(@comments.first().isReply()).toBeTruthy()

        it 'should have the parent id of its collection', ->
          expect(@comments.first().get('parent_id')).toBe(1)

      it 'should know that it has a parent', ->
        expect(@comments.hasParent()).toBeTruthy()

  describe 'comment controller', ->
    beforeEach ->
      loadFixtures 'comment_fixture'
      @xhr = sinon.useFakeXMLHttpRequest()
      @event_id = '123asdf'

      @event = new FK.Models.Event
        _id: @event_id

      @controller = FK.App.Comments.create({
        domLocation: '#comment-spot',
        username: 'event-lover',
        event: @event
      })

      @controller.collection.set [
        { _id: 1, message: 'Hello world', event_id: @event_id, username: 'sam', replies: [
          { _id: 4, message: 'Hello back', event_id: @event_id, username: 'jeff', parent_id: 1 }
          { _id: 5, message: 'Good times...', event_id: @event_id, username: 'claire', parent_id: 1 }
        ] }
        { _id: 2, message: 'Hello universe', event_id: @event_id, username: 'max' }
        { _id: 3, message: 'Hello... planet?', event_id: @event_id, username: 'jeff' }
      ]

    afterEach ->
      @xhr.restore()

    it 'should have 5 views registered in its registry of comment views', ->
      expect(_.values(@controller.commentViews).length).toBe(5)

    it 'should render the comment entry box', ->
      expect(@controller.layout.$('.reply-box').length).toBe(1)

    it 'should render 3 comments at root level', ->
      expect(@controller.commentsListView.children.length).toBe(3)

    it 'should render 2 replies under the first comment', ->
      expect(@controller.commentsListView.$('.comment-list .comment').length).toBe(2)

    it 'should start with the comment button disabled', ->
      expect(@controller.commentBox.$('[data-action="comment"].disabled').length).toBe(1)

    describe 'making a comment', ->
      beforeEach ->
        @commentBox = @controller.commentBox
        @commentBox.$('textarea').val('New idea')
        @commentBox.$('textarea').keyup()

      it 'should have the comment button enabled', ->
        expect(@commentBox.$('[data-action="comment"].disabled').length).toBe(0)

      it 'should not have a cancel button', ->
        expect(@commentBox.$('[data-action="cancel"]').length).toBe(0)

      describe 'submitting a comment', ->
        beforeEach ->
          @commentBox.$('[data-action="comment"]').click()

        it 'should have a new node in the comment view list', ->
          expect(_.values(@controller.commentViews).length).toBe(6)

        it 'should have the comment box emptied', ->
          expect(@commentBox.commentValue()).toBe('')

        it 'should have the comment button disabled again', ->
          expect(@controller.commentBox.$('[data-action="comment"].disabled').length).toBe(1)

    describe 'making a reply', ->
      beforeEach ->
        @comment = @controller.collection.first()
        @replyTo = @controller.commentViews[@comment.cid]
        @controller.openReply(@replyTo.replyBoxRegion, @replyTo.model.replies)

      it 'should have a reply box open under the replying comment', ->
        expect(@replyTo.$('.reply-box').length).toBe(1)

      describe 'when submitting a reply', ->
        beforeEach ->
          @replyBox = @replyTo.replyBoxRegion.currentView
          @replyBox.$('.reply-box textarea').val('reply')
          @replyBox.$('[data-action="comment"]').click()

        it 'should have a cancel button', ->
          expect(@replyBox.$('[data-action="cancel"]').length).toBe(1)

        it 'should have a new node in the comments view list', ->
          expect(_.values(@controller.commentViews).length).toBe(6)

        it 'should have a new reply under the parent comment', ->
          expect(@comment.replies.length).toBe(3)

        it 'should remove the reply box after reply submit', ->
          expect(@replyTo.$('.reply-box').length).toBe(0)
    
    describe 'making a reply to a reply', ->
      beforeEach ->
        @reply = @controller.collection.first().replies.first()
        @replyTo = @controller.commentViews[@reply.cid]
        @controller.openReply(@replyTo.replyBoxRegion, @replyTo.model.replies)
        @replyTo.$('textarea').val('reply reply')
        @replyTo.$('[data-action="comment"]').click()

      it 'should make a reply to the reply', ->
        expect(@reply.replies.length).toBe(1)

      it 'should have a new view in the comments registry', ->
        expect(_.values(@controller.commentViews).length).toBe(6)

    describe 'when closing', ->
      beforeEach ->
        @controller.close()

      it 'should not have any comments shown', ->
        expect(@controller.layout.$('.comment').length).toBe(0)

      it 'should not have any reply or comment boxes shown', ->
        expect(@controller.layout.$('.reply-box').length).toBe(0)

  describe 'without a username', ->
    beforeEach ->
      loadFixtures 'comment_fixture'
      @event = new FK.Models.Event
        _id: @event_id

      @controller = FK.App.Comments.create({
        domLocation: '#comment-spot',
        event: @event
      })

      @controller.collection.set [
        { _id: 1, message: 'Hello world', event_id: @event_id, username: 'sam' }
        { _id: 3, message: 'Hello... planet?', event_id: @event_id, username: 'jeff' }
      ]

    it 'should not have a comment box', ->
      expect(@controller.layout.$('.reply-box').length).toBe(0)

    it 'should have all the comments in the collection listed', ->
      expect(@controller.layout.$('.comment').length).toBe(2)

    describe 'replying', ->
      beforeEach ->
        @commentView = @controller.commentViews[@controller.collection.first().cid]
        @commentView.$('.reply').click()

      it 'should not open a reply box', ->
        expect(@commentView.$('.reply-box').length).toBe(0)
