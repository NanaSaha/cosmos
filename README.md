This app is developed in ruby rack-based framework, Sinatra. I chose this over Ruby on rails because i needed something lightweight just to do 
what i only need and ignore the additional configurations rails add.

To run this app, you need to have :

1.Ruby version > 2.5
2. Bundle install to run the files in the Gemfile
3. Run ruby main.rb to start the app locally.
4. You can now browse the flight interface on http://localhost:4567

API ENDPOINTS

To Generate flights with parameters: http://{{base_url}}/cosmos/check_flights
To display all flights: http://{{base_url}}/cosmos/all_flights

PARAMETERS
destination: "xxxxx,
airline: "xxxx" 
CONTENT_TYPE is in json format


RUN TESTS

Tests are done using Rspec. For sinatra we have to add the rack-test gem and the spec-helper.rb file. Tests are found in the spec folder.
To run the test run bundle exec rspec

DEPLOYMENTS 
I chose the deploy this on a digital ocean VPS
Base url for both API and the web interface can be accessed here http://cosmosproject.duckdns.org/
