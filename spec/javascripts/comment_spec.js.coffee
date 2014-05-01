describe 'comments', ->
  describe 'when commenting', ->
    beforeEach ->
      @comments = new FK.App.Comments.CommentList()
      @comments.comment('grayden', 'Warbling in the dark')

    it 'should be able to comment', ->
      expect(@comments.length).toBe(1)

    it 'should have the correct username on the comment', ->
      expect(@comments.first().get('user')).toBe('grayden')

    it 'should have the correct body on the comment', ->
      expect(@comments.first().get('body')).toBe('Warbling in the dark')
