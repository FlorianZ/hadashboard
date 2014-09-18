# Send a heartbeat message to keep the event stream open
SCHEDULER.every '10m', :first_in => 0 do |job|
  event = "heartbeatTimeout: 45000\n\n"
  Sinatra::Application.settings.connections.each { |out| out << event }
end
