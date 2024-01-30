require "http"
require "json"

puts "What is your location? "

location = gets.chomp # Prompt for user's location

gmaps_key = ENV.fetch("GMAPS_KEY") # Set gmaps key to variable

gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_key}" # url of google geocode

gmaps_data = HTTP.get(gmaps_url) # Send request to gmaps and save response to variable

parsed_gmaps_data = JSON.parse(gmaps_data) # Parse response into JSON format

results = parsed_gmaps_data.fetch("results") # Save results array into variable

geometry = results[0]["geometry"] # Save geometry hash to variable

location_elem = geometry["location"] # Save location hash to variable

lat = location_elem["lat"] # Save latitude to variable

lng = location_elem["lng"] # Save longitude to variable

puts "#{location} coordinates: #{lat}, #{lng}." # Print coordinates of location

pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY") # Save pirate weather key to variable

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{lat},#{lng}" # Save weather url to variable

weather_data = HTTP.get(pirate_weather_url) # Send request to weather api and save response to variable

parsed_weather_data = JSON.parse(weather_data) # Parse response to JSON format

currently_hash = parsed_weather_data.fetch("currently") # Save currently hash to variable

current_temp = currently_hash.fetch("temperature") # Save the current temperature to variable

puts "It is currently #{current_temp}°F." # Print current temperature

minutely = parsed_weather_data.fetch("minutely", false) # Save minutely hash to variable, or false if there isn't one

if minutely
  next_hour_summary = minutely.fetch("summary") 

  puts "Next hour: #{next_hour_summary}" # prints next hour summary
end

hourly = parsed_weather_data.fetch("hourly") # Save hourly hash to variable

hourly_data = hourly.fetch("data") # Save data hash to variable

next_twelve_hours = hourly_data[1..12] # Create hourly range of 1 to 12

precip_prob_limit = 0.10 # Limit to compare precipitation probability

any_precipitation = false # Create variable for any precipitation, defaulting to false

next_twelve_hours.each do |hour|
  precip_prob = hour.fetch("precipProbability")

  if precip_prob > precip_prob_limit # if a precipitation prob is greater than limit
    any_precipitation = true # Set precipitation variable to true

    precip_time = Time.at(hour.fetch("time")) # Save time to variable

    seconds = precip_time - Time.now # Convert time to seconds

    hours = seconds / 60 / 60 # Convert seconds to hours

    puts "In #{hours.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation." # Print when there will be precipitation
  end
end

if any_precipitation == true # Print whether you need umbrella
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end
