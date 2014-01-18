describe "Event Store", ->
  beforeEach ->
    @store = new FK.EventStore(FK.SpecHelpers.Events.UpvotedEvents, 3)
    @store.events.trigger "sync"

  describe "top ranked events", ->
    beforeEach ->
      @topRanked = @store.topRanked

    it "should have 10 events in the top ranked collection", ->
      expect(@topRanked.length).toBe(10)

    it "should not have events outside the date range no matter their ranking", ->
      expect(@topRanked.where({upvotes: 12})).toEqual([])

    it "should have the highest ranked event as the first event in the collection", ->
      expect(@topRanked.first().upvotes()).toBe(11)

    it "should have the lowest of the top ranked events as the last event in the collection", ->
      expect(@topRanked.last().upvotes()).toBe(2)

    describe "when adding an event", ->
      beforeEach ->
        @store.events.add upvotes: 20, datetime: moment().add('days', 5)

      it "should have the new highest event as the first item in the collection", ->
        expect(@topRanked.first().upvotes()).toBe(20)

      it "should have the lowest event bumped out of the collection", ->
        expect(@topRanked.last().upvotes()).toBe(3)

  describe "blocks", ->
    beforeEach ->
      @blocks = @store.blocks

    it "should have a block for each event date up to 3", ->
      expect(@blocks.length).toBe(3)

    it "should have the earliest event date as the date of the first block", ->
      expect(@blocks.first().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 1).format('YYYY-MM-DD'))

    describe "increasing number of blocks", ->
      beforeEach ->
        @store.moreBlocks(2)

      it "should be able to create blocks equal to the number requested", ->
        expect(@blocks.length).toBe(5)

      it "should have the same date on the first block as before", ->
        expect(@blocks.first().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 1).format('YYYY-MM-DD'))
        
      it "should have the latest event on the last block", ->
        expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 5).format('YYYY-MM-DD'))

    describe "getting the limit of blocks in local memory", ->
      beforeEach ->
        @store.moreBlocks(4)

      it "should be able to convert all events in local memory to blocks", ->
        expect(@blocks.length).toBe(7)

      it "should have the date of the last block as the same as the event furthest in the future", ->
        expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(
          @store.events.sortBy( (event) -> event.get('datetime'))[@store.events.length - 1].get('datetime').format('YYYY-MM-DD'))
        

    describe "increasing the number of blocks beyond the number of already fetched events", ->
      beforeEach ->
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr

        @store.moreBlocks(7)

      afterEach ->
        @xhr.restore()
      
      it "should be able to get events by date from the server when there aren't enough events locally", ->
        expect(@requests.length).toBe(1)

      describe "when the server responds", ->
        beforeEach ->
          @requests[0].respond(200, { "Content-Type": "application/json"}, JSON.stringify([
            { datetime: moment().add('days', 12) }
            { datetime: moment().add('days', 12) }
            { datetime: moment().add('days', 12) }
          ]))

        it "should also add all the new events to the events collection", ->
          expect(@store.events.length).toBe(18)

        it "should be able to add more blocks after more events have come back from the server", ->
          expect(@blocks.length).toBe(8)

        it "should be able to set the blocks count to the number of blocks when there are no more blocks to make", ->
          expect(@store.howManyBlocks).toBe(8)
