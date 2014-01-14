namespace :db do
  task :seed do
    Country.delete_all

    IO.readlines('db/countries.csv').each_with_index do |line, index|
      l_split = line.split(',')
      Country.create! code: l_split[0] , en_name: l_split[1], order: index
    end
    Event.delete_all
    Event.create! datetime: 2.weeks.ago, name: "The once loved", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone', 'marionette', 'ruby'], location_type: 'international'
    Event.create! datetime: DateTime.now, name: "Koala Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone'], location_type: 'international'
    Event.create! datetime: DateTime.now, is_all_day: true, name: "Giraffe Day", description:"lorem ipsum", user: "rails", location_type: 'national', country: 'US'
    Event.create! datetime: 2.days.from_now, name: "Zebra Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby'], location_type: 'international'
    Event.create! datetime: 2.days.from_now, name: "Melon Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php'], location_type: 'national', country: 'CA'
    Event.create! datetime: 2.days.from_now, name: "History Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine', 'github', 'backbone'], location_type: 'national', country: 'CA'
    Event.create! datetime: 2.days.from_now, name: "Lion Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'international'
    Event.create! datetime: 2.days.from_now, name: "a great event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'national', country: 'CA'
    Event.create! datetime: 2.days.from_now, name: "a greater event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby'], location_type: 'international'
    Event.create! datetime: 4.days.from_now, name: "Nap time", description:"lorem ipsum", user: "rails", upvote_names: ['rails'], location_type: 'international'
    Event.create! datetime: 4.days.from_now, name: "Something", description:"lorem ipsum", user: "rails", upvote_names: [], location_type: 'national', country: 'CA'
    Event.create! datetime: 4.days.from_now, name: "Appocalypse", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine', 'github'], location_type: 'national', country: 'CA'
    Event.create! datetime: 4.days.from_now, name: "24 Season Premier", description:"lorem ipsum", user: "rails", upvote_names: ['rails' 'jasmine'], location_type: 'international'
    Event.create! datetime: 8.days.from_now, name: "12 Season Premier", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'php', 'jasmine'], location_type: 'national', country: 'US'
    Event.create! datetime: 8.days.from_now, name: "Movie night", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'international'
    Event.create! datetime: 8.days.from_now, name: "Solar Eclipse", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php'], location_type: 'international'
    Event.create! datetime: 8.days.from_now, name: "Mystery party", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'international'
  end 

  task :resave => :environment do
    Event.all.each { |event| event.save }
  end
end
