describe "Event Store", ->
  
  describe "top ranked events", ->
    beforeEach ->
      @store = new FK.EventStore(events: FK.SpecHelpers.Events.UpvotedEvents, howManyStartingBlocks: 3)
      @store.events.trigger "sync"
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
      @store = new FK.EventStore events: FK.SpecHelpers.Events.BlockEvents
      @store.events.trigger "sync"
      @blocks = @store.blocks

    it "should have the earliest event date as the date of the first block", ->
      expect(@blocks.first().get('date').format('YYYY-MM-DD')).toBe(moment().add('days').format('YYYY-MM-DD'))

    it "should have the latest event date as the date of the last block", ->
      expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 3).format('YYYY-MM-DD'))

    describe "adding events to a block", ->
      beforeEach ->
        @blocks.last().increaseLimit 3

      it "should have the new events in the block", ->
        expect(@store.blocks.last().events.length).toBe(5)

      it "should still have the event with the highest number of upvotes first", ->
        expect(@store.blocks.last().events.first().upvotes()).toBe(9)

    describe "increasing the number of blocks beyond the number of already fetched events", ->
      beforeEach ->
        @store = new FK.EventStore events: FK.SpecHelpers.Events.UpvotedEvents
        @store.events.trigger "sync"
        @blocks = @store.blocks
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (xhr) =>
          @requests.push xhr

        @store.loadNextEvents(7)

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

        it "should have the events loaded into the newly created block", ->
          expect(@blocks.last().events.length).toBe(3)

        it "should have a date on the new event block", ->
          expect(@blocks.last().get('date').format('YYYY-MM-DD')).toBe(moment().add('days', 12).format('YYYY-MM-DD'))
