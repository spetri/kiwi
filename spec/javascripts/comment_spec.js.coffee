describe 'comments', ->
  describe 'when commenting', ->
    beforeEach ->
      @xhr = sinon.useFakeXMLHttpRequest()
      @requests = []
      @xhr.onCreate = (xhr) =>
        @requests.push(xhr)

      @event = new FK.Models.Event()
      @event.set('_id', '12345567')
      @comments = new FK.Collections.Comments()
      @comments.fetchForEvent(@event)
      @comments.username = 'joekool'

      @requests[0].respond(200, [])

      @comments.comment('Warbling in the dark')

    afterEach ->
      @xhr.restore()

    it 'should be able to comment', ->
      expect(@comments.length).toBe(1)

    it 'should have the correct body on the comment', ->
      expect(@comments.first().get('message')).toBe('Warbling in the dark')

    it 'should have the correct username', ->
      expect(@comments.first().get('username')).toBe('joekool')
