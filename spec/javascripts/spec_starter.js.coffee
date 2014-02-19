# Force all test cases to use Jan 16 at 2:20 pm as the current date time
sinon.useFakeTimers(1389891600000, "Date")

FK.SpecHelpers =
  Events:
    SimpleEvents: [
      new FK.Models.Event { _id: 1, upvotes: 2, datetime: moment()}
      new FK.Models.Event { _id: 2, upvotes: 5, datetime: moment().add('minutes', 3) }
      new FK.Models.Event { _id: 3, upvotes: 3, datetime: moment().add('minutes', 7) }
      new FK.Models.Event { _id: 4, upvotes: 1, datetime: moment().add('days', 3) }
    ]
    TodayEvents: [
      new FK.Models.Event { _id: 1, datetime: moment().add('seconds', 2) }
      new FK.Models.Event { _id: 2, datetime: moment().add('minutes', 3) }
      new FK.Models.Event { _id: 3, datetime: moment().add('minutes', 7) }
      new FK.Models.Event { _id: 4, datetime: moment().add('hours', 3) }
    ]
    BlockEvents: [
      { _id: 1, upvotes: 2, datetime: moment()}
      { _id: 2, upvotes: 5, datetime: moment().add('minutes', 3) }
      { _id: 3, upvotes: 3, datetime: moment().add('minutes', 7) }
      { _id: 4, upvotes: 3, datetime: moment().add('minutes', 20) }
      { _id: 5, upvotes: 6, datetime: moment().add('hours', 2) }
      { _id: 6, upvotes: 3, datetime: moment().add('hours', 3) }
      { _id: 7, upvotes: 5, datetime: moment().add('days', 3) }
      { _id: 8, upvotes: 9, datetime: moment().add('days', 3) }
      { _id: 9, upvotes: 2, datetime: moment().add('days', 3) }
      { _id: 10, upvotes: 10, datetime: moment().add('days', 3) }
      { _id: 11, upvotes: 3, datetime: moment().add('days', 3) }
      { _id: 12, upvotes: 8, datetime: moment().add('days', 3) }
      { _id: 13, upvotes: 9, datetime: moment().add('days', 3) }
    ]
    PastTodayEvents: [
      { name: 'event 1', datetime: moment().subtract('hours', 4) }
      { name: 'event 2', datetime: moment().subtract('minutes', 20) }
      { name: 'event 3', datetime: moment().add('days', 2) }
    ]
    UpvotedEvents: [
        { name: 'event 1', upvotes: 9, datetime: moment().subtract('days', 1)}
        { name: 'event 2', upvotes: 8, datetime: moment().subtract('days', 1)}
        { name: 'event 2a', upvotes: 8, datetime: moment().subtract('hours', 1)}
        { name: 'event 3', upvotes: 7, datetime: moment().add('days', 1)}
        { name: 'event 4', upvotes: 9, datetime: moment()}
        { name: 'event 5', upvotes: 11, datetime: moment().add('days', 1)}
        { name: 'event 6', upvotes: 11, datetime: moment().add('days', 4)}
        { name: 'event 7', upvotes: 12, datetime: moment().add('days', 10)}
        { name: 'event 8', upvotes: 4, datetime: moment().add('days', 2)}
        { name: 'event 9', upvotes: 3, datetime: moment().add('days', 3)}
        { name: 'event 10', upvotes: 2, datetime: moment().add('days', 7)}
        { name: 'event 11', upvotes: 5, datetime: moment().add('days', 1)}
        { name: 'event 12', upvotes: 3, datetime: moment().add('days', 5)}
        { name: 'event 13', upvotes: 2, datetime: moment().add('days', 4)}
        { name: 'event 14', upvotes: 2, datetime: moment().add('days', 2)}
        { name: 'event 15', upvotes: 5, datetime: moment().add('days', 3)}
    ],
    UpvotedEventsWithCountries: [
        { name: 'event 1', upvotes: 9, datetime: moment().subtract('days', 1), country: 'CA', location_type: 'national'}
        { name: 'event 2', upvotes: 8, datetime: moment().subtract('days', 1), country: 'CA', location_type: 'national'}
        { name: 'event 2a', upvotes: 8, datetime: moment().subtract('hours', 1), country: 'US', location_type: 'national'}
        { name: 'event 3', upvotes: 7, datetime: moment().add('days', 1), country: 'US', location_type: 'national' }
        { name: 'event 4', upvotes: 9, datetime: moment(), country: 'US', location_type: 'national' }
        { name: 'event 5', upvotes: 11, datetime: moment().add('days', 1), country: 'CA', location_type: 'national' }
        { name: 'event 6', upvotes: 11, datetime: moment().add('days', 4), country: 'US', location_type: 'national' }
        { name: 'event 7', upvotes: 12, datetime: moment().add('days', 10), country: 'CA', location_type: 'national' }
        { name: 'event 8', upvotes: 4, datetime: moment().add('days', 2), country: 'CA', location_type: 'national' }
        { name: 'event 9', upvotes: 3, datetime: moment().add('days', 3), country: 'US', location_type: 'national' }
        { name: 'event 10', upvotes: 2, datetime: moment().add('days', 7), country: 'CA', location_type: 'national' }
        { name: 'event 11', upvotes: 5, datetime: moment().add('days', 1), location_type: 'international' }
        { name: 'event 12', upvotes: 3, datetime: moment().add('days', 5), country: 'AM', location_type: 'national' }
        { name: 'event 13', upvotes: 2, datetime: moment().add('days', 4), country: 'CA', location_type: 'national' }
        { name: 'event 14', upvotes: 2, datetime: moment().add('days', 2), country: 'CA', location_type: 'national' }
        { name: 'event 15', upvotes: 5, datetime: moment().add('days', 3), country: 'CA', location_type: 'national' }
    ]
