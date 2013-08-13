namespace :db do
  task :seed do
    Country.delete_all

    IO.readlines('db/countries.csv').each_with_index do |line, index|
      l_split = line.split(',')
      Country.create! code: l_split[0] , en_name: l_split[1], order: index
    end

    Event.delete_all
    Event.create! datetime: DateTime.now, title: "a great event", details:"lorem ipsum", user: "jl"
    Event.create! datetime: 4.days.ago, title: "a great event", details:"lorem ipsum", user: "jl"
    Event.create! datetime: 4.days.ago, title: "a great event", details:"lorem ipsum", user: "jl"
  end 
end
