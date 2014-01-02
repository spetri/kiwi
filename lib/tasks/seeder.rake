namespace :db do
  task :seed do
    Country.delete_all

    IO.readlines('db/countries.csv').each_with_index do |line, index|
      l_split = line.split(',')
      Country.create! code: l_split[0] , en_name: l_split[1], order: index
    end
    Event.delete_all
    Event.create! datetime: DateTime.now, name: "Koala Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone']
    Event.create! datetime: DateTime.now, name: "Giraffe Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'github']
    Event.create! datetime: 2.days.from_now, name: "Zebra Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby']
    Event.create! datetime: 2.days.from_now, name: "Melon Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php']
    Event.create! datetime: 2.days.from_now, name: "History Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine', 'github', 'backbone']
    Event.create! datetime: 2.days.from_now, name: "Lion Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine']
    Event.create! datetime: 2.days.from_now, name: "a great event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine']
    Event.create! datetime: 2.days.from_now, name: "a greater event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby']
    Event.create! datetime: 4.days.from_now, name: "Nap time", description:"lorem ipsum", user: "rails", upvote_names: ['rails']
    Event.create! datetime: 4.days.from_now, name: "Something", description:"lorem ipsum", user: "rails", upvote_names: []
    Event.create! datetime: 4.days.from_now, name: "Appocalypse", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine', 'github']
    Event.create! datetime: 4.days.from_now, name: "24 Season Premier", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine']
  end 
end
