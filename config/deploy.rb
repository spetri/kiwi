require 'json'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
 require 'mina/rvm'    # for rvm support. (http://rvm.io)
require 'HipChat'
config_file = File.expand_path('../application.yml', __FILE__)
if (File.exists?(config_file))
  CONFIG = YAML.load(File.read(config_file))
  CONFIG.merge! CONFIG.fetch('production', {})
else
  CONFIG = {}
end
# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, ENV['host'] || (puts "enter a 'host' to deploy to"; exit )
set :deploy_to, '/srv/www/forekast'
set :repository, 'git@github.com:Forekasting/kiwi.git'
set :branch, 'master'

set :pid_file, "#{deploy_to}/shared/tmp/pids/server.pid"

set :app_port, '4000'
set :app_path, lambda { "#{deploy_to}/#{current_path}" }

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/mongoid.yml', 'config/application.yml', 'public/system', 'config/puma.rb', 'log', 'tmp', 'config/newrelic.yml']

set :pid_file, "#{deploy_to}/shared/tmp/pids/puma.pid"
set :state_file, "#{deploy_to}/shared/tmp/puma/state"

# Optional settings:
set :user, 'rails'    # Username in the server to SSH to.
set :ssh_options, '-t -A'  # ensure that ssh agent forwarding is being used.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.1.1@kiwi]'

end

set :rvm_path, "/usr/local/rvm/scripts/rvm"

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/public"]
  queue! %[mkdir -p "#{deploy_to}/shared/public/system"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]

  queue  %{ssh-keyscan github.com > /home/#{user}/.ssh/known_hosts}

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/puma"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/puma"]

  queue  %{ touch "#{deploy_to}/shared/config/puma.rb"}
  queue  %{ echo "pidfile \\"#{pid_file}\\"" > #{deploy_to}/shared/config/puma.rb }
  queue  %{ echo "state_path \\"#{state_file}\\"" >> #{deploy_to}/shared/config/puma.rb }
  queue  %{ echo "port \"#{app_port}\"" >> #{deploy_to}/shared/config/puma.rb }
  queue  %{ echo "daemonize true" >> #{deploy_to}/shared/config/puma.rb }
  queue  %{ echo "environment \\"#{rails_env}\\"" >> #{deploy_to}/shared/config/puma.rb }
  queue  %{ echo "activate_control_app" >> #{deploy_to}/shared/config/puma.rb }

  queue  %{ echo "Adding to puma.conf" }
  queue  %{ sudo sh -c "echo \"#{app_path},#{user},#{app_path}/config/puma.rb,#{app_path}/log/puma.log\" > /etc/puma.conf "}
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    notify("#{ENV['host']} - deploying! ", 'green')
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
  end
end

task :deploy_assets => :environment do
  deploy do
    notify("#{ENV['host']} - deploying assets! ", 'green')
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:assets_precompile'
  end
end

desc 'Starts the application'
task :start => :environment do
    notify("#{ENV['host']} - starting! ", 'purple')
    queue! %{sudo service puma start}
end

desc 'Stops the application'
task :stop => :environment do
    notify("#{ENV['host']} - stopping! ", 'gray')
    queue! %{sudo service puma stop}
end

desc 'Restarts the application'
task :restart => :environment do
    notify("#{ENV['host']} - restarting! ", 'green')
    queue! %{sudo service puma restart}
end

desc 'Cleanups old all day values'
task :cleanup_all_day => :environment do
  notify("#{ENV['host']} - cleaning up all day! ", 'green')
  queue "cd #{deploy_to}/current ; bundle exec rake db:cleanup_all_day RAILS_ENV=production"
end

desc 'Move to local date field from date'
task :move_to_local_date => :environment do
  notify("#{ENV['host']} - moving to local date! ", 'green')
  queue "cd #{deploy_to}/current ; bundle exec rake db:move_date_to_local_date RAILS_ENV=production"
end

desc 'Populate crontab of this server with recurring tasks'
task :update_cron => :environemnt do
  notify("#{ENV['host'} - updating crontab ", "blue")
  queue "cd #{deploy_to}/current; bundle exec whenever --update-crontab kiwi --set 'environment=production&path=#{deploy_to}/#{current_path}"
end

desc 'Prime db for production'
task :prime_db => :environment do
  notify("#{ENV['host']} - priming database! ", 'green')
  queue "cd #{deploy_to}/current ; bundle exec rake db:empty_seed RAILS_ENV=production"
end

desc 'Seed subkasts'
task :seed_subkasts => :environment do
  queue "cd #{deploy_to}/current; bundle exec rake db:seed_subkasts RAILS_ENV=production"
end

task :all_users_to_default => :environment do
  queue "cd #{deploy_to}/current; bundle exec rake db:all_users_to_default RAILS_ENV=production"
end

desc "Cold Deploy the application for the first time"
task :cold_deploy => :environment do
  notify("#{ENV['host']} - cold deploy! ", 'green')
  invoke :setup
  invoke :deploy
  invoke :start
end

desc "Full deployment start stop restart!!!!"
task :full_deploy => :environment do
  invoke :deploy
  invoke :stop
  invoke :start
  notify("#{ENV['host']} - Full Deployment Done! kthxbye ", 'green')
end

def notify(message, color)
  client = HipChat::Client.new(CONFIG['hipchat_api_token'])
  client[CONFIG['hipchat_room']].send('kiwibot', message, :color => color)
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

