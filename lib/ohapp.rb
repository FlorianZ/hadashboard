require 'net/https'
require 'json'

#
# Object grants REST-ful access to a ST SmartApp endpoint. This
# object also handles authorization with SmartThings.
# 
class OHApp
  OPENHAB_SERVER = "localhost"
  OPENHAB_PORT = 7070

  attr_reader :temperature, :currentConditions, :humidity, :pressure, :precipitation, :windSpeed, :temperatureLow, 
    :temperatureHigh, :weatherIcon, :weatherCode, :tomorrowTemperatureLow, :tomorrowTemperatureHigh, :tomorrowWeatherIcon, :tomorrowPrecipitation,
    :windSpeed, :windDirection, :windGust, :weatherObsTime, :sunrise, :sunset

  def initialize()
    #@endpoint = endpoint
    @temperature=0.0
    @currentConditions=""
    @humidity=0.0
    @pressure=0.0
    @precipitation=0
    @windSpeed=0
    @temperatureLow=0.0
    @temperatureHigh=0.0
    @weatherIcon=""
    @weatherCode=""
    @tomorrowTemperatureLow=0.0
    @tomorrowTemperatureHigh=0.0
    @tomorrowPrecipitation=0
    @tomorrowWeatherIcon=""
    @weatherObsTime=nil
    @windSpeed=0
    @windGust=0
    @windDirection=""
    @sunrise=nil
    @sunset=nil
  end

  # openHAB REST call
  def getState(itemID, data)
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/rest/items/#{itemID}?type=json"))
    puts response.body()
    response.body()
  end

  def sendCommand(itemID, newState, data)
    puts "[DEBUG] posting REST command: '/CMD?#{itemID}=#{newState}'"
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/CMD?#{itemID}=#{newState}"))
    puts response.body()
    response.body()
  end

  def refreshWeather()
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/rest/items/Weather?type=json"))
    #puts response.body()
    data = JSON.parse(response.body())
    #puts data
    data["members"].each do |member|
      #p member["name"] + ": " + member["state"]
      value = member["state"]

      case member["name"]
        when "Weather_Temperature"
          @temperature=value.to_f.round 
        when "Weather_Conditions"
          @currentConditions = value
        when "Weather_Code"
          @weatherCode = value           
          @weatherIcon = (value.gsub "-","").gsub "day",""
        when "Weather_Temp_Max_0"
          @temperatureHigh = value.to_f.round               
        when "Weather_Temp_Min_0"
          @temperatureLow = value.to_f.round    
        when "Weather_Humidity"
          @humidity = value.to_f.round 
        when "Weather_Pressure"
          @pressure = value.to_f.round 
        when "Weather_Temp_Max_1"
          @tomorrowTemperatureHigh = value.to_f.round    
        when "Weather_Temp_Min_1"
          @tomorrowTemperatureLow = value.to_f.round    
        when "Sunrise_Time"
          @sunrise = value
        when "Sunset_Time"
          @sunset = value
        when "Weather_ObsTime"
          @weatherObsTime = value
        when "Weather_Code_1"
          @tomorrowWeatherIcon = (value.gsub "-","").gsub "day",""
        when "Weather_Precipitation"
          @precipitation = value[0..-4]
        when "Weather_Precipitation_1"
          @tomorrowPrecipitation=value.to_f.round           
        when "Weather_Wind_Speed"
          @windSpeed=value.to_f.round 
        when "Wind_Direction"
          @windDirection=value
        when "Wind_Gust"
          @windGust=value.to_f.round 
      end
    end

    puts self.to_yaml
    data
  end

  def getWeather()


  end


    
  # SCHEDULER.every '5m', :first_in => 0 do |job|
  #   http = Net::HTTP.new("api.forecast.io", 443)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  #   response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  #   forecast = JSON.parse(response.body)  
  #   forecast_current_temp = forecast["currently"]["temperature"].round
  #   forecast_hour_summary = forecast["minutely"]["summary"]
  #   send_event('forecast', { temperature: "#{forecast_current_temp}&deg;", hour: "#{forecast_hour_summary}"})
  # end

#  private :refreshToken, :getEndpoint, :retrieveToken, :storeToken

end