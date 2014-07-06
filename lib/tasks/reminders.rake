namespace :reminders do
  task :send_reminders => :environment do |t, args|
    Reminder.send_reminders
  end
end
