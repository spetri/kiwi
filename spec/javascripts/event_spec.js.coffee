# use require to load any .js file available to the asset pipeline
#= require application

describe "Event", ->
  loadFixtures 'event_fixture' # located at 'spec/javascripts/fixtures/event_fixture.html.erb'
  it "Default country to be US", ->
    v = new FK.Models.Event()
    expect(v.get('country')).toEqual('US')


  it "can get time in eastern", =>
    datetime = moment("2013-12-12, 16:00 GMT+200")
    v = new FK.Models.Event datetime: datetime
    expect(v.get('creation_timezone')).toEqual("GMT+100")
    expect(v.time_in_eastern()).toEqual('10:00')



  it "can detect TV times", =>
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 16:00 GMT+200")
    expect(v.time_in_eastern()).toEqual('10:00')
    expect(v.get('time')).toEqual('4/3c')
    
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 1:00 GMT+200")
    expect(v.get('time')).toEqual('1/12c')
    
    v = new FK.Models.Event time_format: 'tv_show', datetime: moment("2013-12-12, 20:00 GMT+200")
    expect(v.get('time')).toEqual('8/7c')
