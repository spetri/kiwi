PumaWorkerKiller.config do |config|
  config.ram           = 1024 # mb
  config.frequency     = 5    # seconds
  config.percent_usage = 0.75
end
PumaWorkerKiller.start


