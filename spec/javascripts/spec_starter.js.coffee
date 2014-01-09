FK.SpecHelpers =
  Events:
    SimpleEvents: [
      { _id: 1, datetime: moment()}
      { _id: 2, datetime: moment().add('minutes', 3) }
      { _id: 3, datetime: moment().add('minutes', 7) }
      { _id: 4, datetime: moment().add('days', 3) }
    ]
