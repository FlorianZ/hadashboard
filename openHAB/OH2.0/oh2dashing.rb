#!/usr/bin/ruby -w

require 'em-eventsource'
require 'json'

DASHING_AUTH_TOKEN="openH4b"
OPENHAB_URL = "http://localhost:7070"
DASHING_URL = "http://127.0.0.1:3030"

VERBOSE = 0 #0, 1, 2 

def postToDashing(widget,content,state)
    body = { auth_token: DASHING_AUTH_TOKEN}
    body["state"] = state
    bodyJson = body.to_json
    uri = "#{DASHING_URL}/widgets/#{widget}"
    
    if VERBOSE > 1 then puts "Posting: #{bodyJson} to #{uri}" end
    
    http = EventMachine::HttpRequest.new(uri).post :body => bodyJson
    http.errback { 
        p "An error occured posting to #{uri}"
        p "Http error:  #{http.error}"
        # p "Response Header Status:  #{http.response_header.status}"
        p "Response Header: #{http.response_header}"
        p "Response: #{http.response}"
    }
    http.callback {
        if VERBOSE > 1
          p http.response_header.status
          p http.response_header
          p http.response
        end
    }
end

Signal.trap("INT") { 
  exit
}

# Trap `Kill `
Signal.trap("TERM") {
  exit
}

EM.run do
  source = EM::EventSource.new("#{OPENHAB_URL}/rest/events?topics=smarthome/items/*")
  source.inactivity_timeout = 0
  
  source.on "message" do |msgJson|
    msg = JSON.parse(msgJson)
    action = msg["topic"][/([^\/]*)\Z/]            
    if action == "state"
	    path = msg["topic"][/smarthome\/items\/(?<item>.*)\//]      
	    item = $1
	    payloadJSON = msg["payload"]
	    payload = JSON.parse(payloadJSON)
	    state = payload['value']
	    if VERBOSE > 0 
	        puts "item: #{item}, State: #{state}, Action: #{action}"
	        if VERBOSE > 1
	          puts "Message: #{message}" 
	          puts "Path: #{path}, action type: #{action}"
	        end
	    end
	    postToDashing(item, action, state)
    end
  end
  source.error do |error|
    puts "An error occured:  #{error}"
    puts "Restarting connection in 10 seconds..."
    sleep(10)
    source.close
    puts "Reconnecting..."    
    source.start
  end
  source.open do
    puts "Connected to openHAB"
  end
  source.start
end

