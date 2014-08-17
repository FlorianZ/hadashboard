require "net/http"
require "json"

# WOEID for location:
# http://woeid.rosselliot.co.nz
woeid  = 2362930

# Units for temperature:
# f: Fahrenheit
# c: Celsius
format = "f"

query  = URI::encode "select * from weather.forecast WHERE woeid=#{woeid} and u='#{format}'&format=json"

SCHEDULER.every "15m", :first_in => 0 do |job|
  http     = Net::HTTP.new "query.yahooapis.com"
  request  = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results  = response["query"]["results"]

  if results
    condition = results["channel"]["item"]["condition"]
    location  = results["channel"]["location"]
    send_event "klimato", { location: location["city"], temperature: condition["temp"], code: condition["code"], format: format }
  end
end
