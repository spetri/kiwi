namespace :db do
  task :seed do
    Country.delete_all

    IO.readlines('db/countries.csv').each_with_index do |line, index|
      l_split = line.split(',')
      Country.create! code: l_split[0] , en_name: l_split[1], order: index
    end
    Event.delete_all
    Event.create! datetime: 2.weeks.ago, name: "The once loved", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone', 'marionette', 'ruby'], location_type: 'international'
    Event.create! datetime: 8.hours.ago, name: "Geese Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'github', 'backbone'], location_type: 'international'
    Event.create! datetime: 5.hours.ago, name: "Moose Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone', 'php', 'marionette'], location_type: 'international'
    Event.create! datetime: 5.hours.from_now, name: "Koala Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone'], location_type: 'international'
    Event.create! datetime: 6.hours.from_now, is_all_day: true, name: "Giraffe Day", description:"lorem ipsum", user: "rails", location_type: 'national', country: 'US'
    Event.create! datetime: 8.hours.from_now, name: "Zebra Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby'], location_type: 'international'
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
    Event.create! datetime: 9.days.from_now, name: "Magical event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'international'
    Event.create! datetime: 9.days.from_now, name: "Predictable hurricane", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine'], location_type: 'international'
  end 

  task :resave => :environment do
    Event.all.each { |event| event.save }
  end

  task :cleanup_all_day => :environment do
    Event.all.each { |event| 
      if event.is_all_day == "1" or event.is_all_day == "true" or event.is_all_day == true
        event.is_all_day = true;
      else
        event.is_all_day = false;
      end
      event.save
    }
  end
end
