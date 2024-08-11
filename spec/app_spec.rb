# spec/app_spec.rb
require 'rspec'
require 'rack/test'
require_relative '../main'

RSpec.describe 'Flights Data API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

    describe 'POST /cosmos/check_flights' do
    it 'returns a response with valid parameters' do
      post '/cosmos/check_flights', { destination: 'FRA', airline: 'OS' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(JSON.parse(last_response.body)).to be_an(Array)
    end


    context 'response with no parameters' do
      it 'returns a 400 Bad Request response' do
        post '/cosmos/check_flights', {}, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(JSON.parse(last_response.body)['error']).to eq('Parameters are missing. Please provide destination and airline params')
      end
    end
  end



    describe 'GET /cosmos/all_flights' do
    context 'when there are more flights' do
      it 'returns a response' do
       
        allow_any_instance_of(Sinatra::Application).to receive(:retrieve_flight_data).and_return([
          {
            "flight_number" => "EW2759",
            "airline" => "EW",
            "origin" => "VIE",
            "destination" => "STR",
            "scheduled_departure_at" => "2024-06-19T06:35:00Z",
            "actual_departure_at" => "2024-06-19T06:52:00Z",
            "delays" => []
          }
        ])

        get '/cosmos/all_flights'

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        
        response_data = JSON.parse(last_response.body)
        expect(response_data).to be_an(Array)
        expect(response_data.size).to be > 0
        expect(response_data.first).to have_key('flight_number')
        expect(response_data.first).to have_key('airline')
        expect(response_data.first).to have_key('origin')
        expect(response_data.first).to have_key('destination')
      end
    end

    context 'when there are no flights at all' do
      it 'returns an empty response' do
       
        allow_any_instance_of(Sinatra::Application).to receive(:retrieve_flight_data).and_return([])

        get '/cosmos/all_flights'

        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        
        response_data = JSON.parse(last_response.body)
        expect(response_data).to be_an(Array)
        expect(response_data).to be_empty
      end
    end
  end



end
