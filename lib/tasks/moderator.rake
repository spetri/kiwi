namespace :users do
  task :make_moderator => :environment do |t, args|
    user = User.find_by(username: ENV['username'])
    user.moderator = 1
    user.save
  end
end
