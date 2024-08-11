require 'sinatra'
require 'json'
require 'net/http'
require 'securerandom'

set :public_folder, 'public'

# URLs to fetch data from
SCHEDULES_JSON = "https://challenge.usecosmos.cloud/flight_schedules.json"
DELAYS_JSON = "https://challenge.usecosmos.cloud/flight_delays.json"


# retrieve and store all the flight data 
def retrieve_flight_data

  sample_flights_data = []

  # retrieve schedules from the JSON link
  schedules_response = Net::HTTP.get(URI(SCHEDULES_JSON))
  all_schedules = JSON.parse(schedules_response)

  # retrieve delays from the JSON link
  delays_response = Net::HTTP.get(URI(DELAYS_JSON))
  all_delays = JSON.parse(delays_response)


  # Index delays by a specific flight number
  delay_arr = {}
  all_delays.each do |delay|

    flight_num =  delay["Flight"]["OperatingFlight"]&.dig("Number")

    delayCode = delay["FlightLegs"][0]["Departure"]["Delay"]["Code1"]&.dig("Code")

    delayMins = delay["FlightLegs"][0]["Departure"]["Delay"]["Code1"]&.dig("DelayTime")

    delayDesc = delay["FlightLegs"][0]["Departure"]["Delay"]["Code1"]&.dig("Description")

   
     flight_number = delay["Flight"]["OperatingFlight"]["Number"]
     delay_arr[flight_number] ||= []
     delay_arr[flight_number] << {
      "code" => delayCode,
      "time_minutes" => delayMins,
      "description" => delayDesc
    }
  end

  # Process schedules and match with delays
  all_schedules.each do |schedule|
  main_flight_detail = schedule[1]["Flights"]["Flight"]

  main_flight_detail.each do |t|

     # puts "flight_num delay sch --- #{t["MarketingCarrier"]["FlightNumber"]}"


    flight_info = {
      "id" => SecureRandom.uuid,
      "flight_number" => t["MarketingCarrier"]["FlightNumber"],
      "airline" => t["MarketingCarrier"]["AirlineID"],
      "origin" => t["Departure"]["AirportCode"],
      "destination" => t["Arrival"]["AirportCode"],
      "scheduled_departure_at" => t["Departure"]["ScheduledTimeUTC"]["DateTime"],
      "actual_departure_at" => t["Departure"]["ActualTimeUTC"]["DateTime"],
      "delays" => delay_arr[t["MarketingCarrier"]["FlightNumber"]] || []
    }

    sample_flights_data << flight_info
    
  end
 end
  return sample_flights_data
end



# API endpoint to get flight data
post '/cosmos/check_flights' do
  content_type :json

    # Read and parse the request body
  request_body = request.body.read
  begin
    params = JSON.parse(request_body) if request_body && !request_body.empty?
  rescue JSON::ParserError
    status 400
    return { error: 'Invalid format' }.to_json
  end

  # Check if incoming params is nil
  if params.nil?
    status 400
    return { error: 'Parameters are missing. Please provide destination and airline params' }.to_json
  end

  destination = params['destination']
  airline = params['airline']

  filtered_flights = retrieve_flight_data.select do |flight|

   
    (destination.nil? || flight['destination'] == destination) &&
    (airline.empty? || airline.include?(flight['airline']))

  end

  if filtered_flights.empty?
    status 404
    { error: 'No flights found' }.to_json
  else
    #filtered_flights.to_json
     return filtered_flights.to_json
  end
end



# User interface to browse flights
get '/cosmos/all_flights' do
  
content_type :json

  @all_flights = retrieve_flight_data

  @all_flights.to_json
 
end

get '/' do
  

  @all_flights = retrieve_flight_data
  erb :index

 # return retrieve_flight_data.to_json
 
end
