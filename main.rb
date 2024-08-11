require 'sinatra'
require 'json'
require 'net/http'
require 'securerandom'

# Set the public folder to serve static files
set :public_folder, 'public'

# URLs to fetch data from
FLIGHT_SCHEDULES_URL = "https://challenge.usecosmos.cloud/flight_schedules.json"
FLIGHT_DELAYS_URL = "https://challenge.usecosmos.cloud/flight_delays.json"

# In-memory storage


# Fetch and store flight data
def fetch_flight_data

    flights_data = []
  # Fetch schedules
  schedules_response = Net::HTTP.get(URI(FLIGHT_SCHEDULES_URL))
  schedules = JSON.parse(schedules_response)

  # Fetch delays
  delays_response = Net::HTTP.get(URI(FLIGHT_DELAYS_URL))
  delays = JSON.parse(delays_response)

  # Index delays by flight number
  delay_dict = {}
  delays.each do |delay|

    flight_num =  delay["Flight"]["OperatingFlight"]&.dig("Number")

    delayCode = delay["FlightLegs"][0]["Departure"]["Delay"]["Code1"]&.dig("Code")

    delayMins = delay["FlightLegs"][0]["Departure"]["Delay"]["Code1"]&.dig("DelayTime")

    delayDesc = delay["FlightLegs"][0]["Departure"]["Delay"]["Code1"]&.dig("Description")

    # puts "time  -- #{delayMins}"
    # puts "Description  -- #{delayDesc}"
     # puts "flight_num delay --- #{flight_num}"

    # puts "Codes  -- #{delayCode}"

  
  
     flight_number = delay["Flight"]["OperatingFlight"]["Number"]
     delay_dict[flight_number] ||= []
    delay_dict[flight_number] << {
      "code" => delayCode,
      "time_minutes" => delayMins,
      "description" => delayDesc
    }
  end

  # Process schedules and match with delays
schedules.each do |schedule|
  main_flight_detail = schedule[1]["Flights"]["Flight"]


 

  main_flight_detail.each do |t|

     # puts "flight_num delay sch --- #{t["MarketingCarrier"]["FlightNumber"]}"


    flight_dataa = {
      "id" => SecureRandom.uuid,
      "flight_number" => t["MarketingCarrier"]["FlightNumber"],
      "airline" => t["MarketingCarrier"]["AirlineID"],
      "origin" => t["Departure"]["AirportCode"],
      "destination" => t["Arrival"]["AirportCode"],
      "scheduled_departure_at" => t["Departure"]["ScheduledTimeUTC"]["DateTime"],
      "actual_departure_at" => t["Departure"]["ActualTimeUTC"]["DateTime"],
      "delays" => delay_dict[t["MarketingCarrier"]["FlightNumber"]] || []
    }

    flights_data << flight_dataa
    
  end
end
  return flights_data
end

# Initialize data
#flights_details = fetch_flight_data






# API endpoint to get flight data
post '/api/flights' do
  content_type :json

  request_body = request.body.read
  params = JSON.parse(request_body) if request_body && !request_body.empty?

  destination = params['destination']
  airline = params['airline']
  

  #puts "Flight Details #{fetch_flight_data}"

  filtered_flights = fetch_flight_data.select do |flight|

    # puts "Flight loop --- #{flight}"

    # puts "Flight Destina --- #{flight['destination']}"
    #  puts "Flight Destina  PArams--- #{destination}"

    #   puts "airline --- #{flight['airline']}"
    #  puts "airline PArams--- #{airline}"
   
    (destination.nil? || flight['destination'] == destination) &&
    (airline.empty? || airline.include?(flight['airline']))

#   ( (destination.nil? || flight['destination'] == destination) && 
#     (airline.nil? || flight['airline'] == airline) )   || (destination.nil? || flight['destination'] == destination) 
  
  end

  return filtered_flights.to_json
end

# User interface to browse flights
get '/all_flights' do
  

  @flights = fetch_flight_data
 

  return fetch_flight_data.to_json
 
end

get '/' do
  

  @flights = fetch_flight_data
  erb :index

 # return fetch_flight_data.to_json
 
end
