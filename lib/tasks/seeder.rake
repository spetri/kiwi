namespace :db do
  task :empty_seed => [:environment, :seed_subkasts] do
    Country.delete_all
    Event.create! time_format: '', datetime: 2.weeks.ago, local_date: 2.weeks.ago, name: "The once loved", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone', 'marionette', 'ruby'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.delete_all

    IO.readlines('db/countries.csv').each_with_index do |line, index|
      l_split = line.split(',')
      Country.create! code: l_split[0] , en_name: l_split[1], order: index
    end
  end

  task :seed do
    Country.delete_all

    IO.readlines('db/countries.csv').each_with_index do |line, index|
      l_split = line.split(',')
      Country.create! code: l_split[0] , en_name: l_split[1], order: index
    end
    Event.delete_all
    Event.create! time_format: '', datetime: 2.weeks.ago, local_date: 2.weeks.ago, name: "The once loved", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone', 'marionette', 'ruby'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 8.hours.ago, local_date: Date.today(), name: "Geese Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'github', 'backbone'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 5.hours.ago, local_date: Date.today(), name: "Moose Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone', 'php', 'marionette'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 5.hours.from_now, local_date: Date.today(), name: "Koala Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine', 'github', 'backbone'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'HA'
    Event.create! time_format: '', datetime: 6.hours.from_now, local_date: Date.today(), is_all_day: true, name: "Giraffe Day", description:"lorem ipsum", user: "rails", location_type: 'national', country: 'US', subkast: 'ST'
    Event.create! time_format: '', datetime: 8.hours.from_now, local_date: Date.today(), name: "Zebra Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'PRP'
    Event.create! time_format: '', datetime: 2.days.from_now, local_date: 2.days.from_now, name: "Melon Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php'], location_type: 'national', country: 'CA', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 2.days.from_now, local_date: 2.days.from_now, name: "History Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine', 'github', 'backbone'], location_type: 'national', country: 'CA', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 2.days.from_now, local_date: 2.days.from_now, name: "Lion Day", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'TVM'
    Event.create! time_format: '', datetime: 2.days.from_now, local_date: 2.days.from_now, name: "a great event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'national', country: 'CA', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 2.days.from_now, local_date: 2.days.from_now, name: "a greater event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'SE'
    Event.create! time_format: '', datetime: 4.days.from_now, local_date: 4.days.from_now, name: "Nap time", description:"lorem ipsum", user: "rails", upvote_names: ['rails'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 4.days.from_now, local_date: 4.days.from_now, name: "Something", description:"lorem ipsum", user: "rails", upvote_names: [], location_type: 'national', country: 'CA', is_all_day: false, subkast: 'SE'
    Event.create! time_format: '', datetime: 4.days.from_now, local_date: 4.days.from_now, name: "Appocalypse", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine', 'github'], location_type: 'national', country: 'CA', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 4.days.from_now, local_date: 4.days.from_now, name: "24 Season Premier", description:"lorem ipsum", user: "rails", upvote_names: ['rails' 'jasmine'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 8.days.from_now, local_date: 8.days.from_now, name: "12 Season Premier", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'php', 'jasmine'], location_type: 'national', country: 'US', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 8.days.from_now, local_date: 8.days.from_now, name: "Movie night", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 8.days.from_now, local_date: 8.days.from_now, name: "Solar Eclipse", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php'], location_type: 'international', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 8.days.from_now, local_date: 8.days.from_now, name: "Mystery party", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], location_type: 'international', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 9.days.from_now, local_date: 9.days.from_now, name: "Magical event", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'ruby', 'php', 'jasmine'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
    Event.create! time_format: '', datetime: 9.days.from_now, local_date: 9.days.from_now, name: "Predictable hurricane", description:"lorem ipsum", user: "rails", upvote_names: ['rails', 'jasmine'], country: 'CA', location_type: 'national', is_all_day: false, subkast: 'ST'
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

  task :move_date_to_local_date => :environment do
    Event.all.each{ |event|
      event.local_date = event.date
      event.save
    }
  end

  task :give_event_other_subkast => :environment do
    Event.all.each { |event|
      event.subkast = "OTH" if event.subkast.to_s == ''
      event.save
    }
  end

  task :seed_subkasts => :environment do
    Subkast.delete_all
    Subkast.create! name: "Movies", code: "TVM", url: "movies"
    Subkast.create! name: "Sports", code: "SE", url: "sports"
    Subkast.create! name: "Science", code: "ST", url: "science"
    Subkast.create! name: "Technology", code: "TE", url: "technology"
    Subkast.create! name: "HowAboutWe", code: "HAW", url: "howaboutwe"
    Subkast.create! name: "ProductReleases", code: "PRP", url: "productreleases"
    Subkast.create! name: "Holidays", code: "HA", url: "holidays"
    Subkast.create! name: "Education", code: "EDU", url: "education"
    Subkast.create! name: "Music", code: "MA", url: "music"
    Subkast.create! name: "Arts", code: "ART", url: "arts"
    Subkast.create! name: "Gaming", code: "GM", url: "gaming"
    Subkast.create! name: "Other", code: "OTH", url: "other"
  end

  task :all_users_to_default => :environment do
    User.all.each do |user|
      user.defaults
      user.save
    end
  end
end
