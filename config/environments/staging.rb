Rails.application.configure do
  # Set to :debug to see everything in the log.
  config.log_level = :debug
  config.session_store :redis_store, servers: 'redis://XXXX.XXXX.XXXX.XXXX.cache.amazonaws.com:6379/0', expire_in: 1.day
end
