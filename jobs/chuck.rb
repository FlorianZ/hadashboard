require 'net/http'
require 'json'

#The Internet Chuck Norris Database
server = "http://api.icndb.com"

#Id of the widget
id = "chuck"

#Proxy details if you need them - see below
proxy_host = 'XXXXXXX'
proxy_port = 8080
proxy_user = 'XXXXXXX'
proxy_pass = 'XXXXXXX'

#The Array to take the names from
teammembers = [['Check','Norris']]

SCHEDULER.every '30s', :first_in => 0 do |job|
    random_member = teammembers.sample
    firstName = random_member[0]
    lastName = random_member[1]

    #The uri to call, swapping in the team members name
    uri = URI("#{server}/jokes/random?firstName=#{firstName}&lastName=#{lastName}&limitTo=[nerdy]")

    #This is for when there is no proxy
    res = Net::HTTP.get(uri)

    #This is for when there is a proxy
    #res = Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_pass).get(uri)
    
    #marshal the json into an object
    j = JSON[res]

    #Get the joke
    joke = j['value']['joke']

    #Send the joke to the text widget
    send_event(id, { title: "#{firstName} #{lastName} Facts", text: joke })

end
