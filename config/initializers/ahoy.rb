class Ahoy::Store < Ahoy::DatabaseStore
  Ahoy.server_side_visits = :when_needed
end

# set to true for JavaScript tracking
Ahoy.api = true

# better user agent parsing
Ahoy.user_agent_parser = :device_detector

# better bot detection
# Ahoy.bot_detection_version = 2
# Ahoy.track_bots = true

#Ahoy.api_only = true
