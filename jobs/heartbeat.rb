# Send a heartbeat message to keep the event stream open
SCHEDULER.every '7s', :first_in => 0 do |job|
  event = "heartbeatTimeout: 15000\n\n"
  Sinatra::Application.settings.connections.each { |out| out << event }
end
