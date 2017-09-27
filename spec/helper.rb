require 'nexosis_api'
require 'vcr'
require 'rspec'
require 'json'

RSpec.configure do |config|
  config.around(:each, :vcr) do |example|
    handle_vcr(example)
  end
  config.before(:all) do
    begin
      data = CSV.open('spec/fixtures/sampledata.csv', 'rb', headers: true)
      nts_data = JSON.load(File.open('spec/fixtures/housedata.json'))
      test_client.create_dataset_csv('TestRuby', data)
      test_client.create_dataset_json('TestRuby_NTS', nts_data)
    rescue Exception => eApi
      puts eApi.message
    end
  end

  config.after(:all) do
    begin
      test_client.remove_dataset('TestRuby', cascade: true)
      test_client.remove_dataset('TestRuby_NTS', cascade: true)
    rescue NexosisApi::HttpException
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.filter_sensitive_data('api-key') { ENV['NEXOSIS_API_TESTKEY'] }
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
end

def test_api_key
  ENV.fetch 'NEXOSIS_API_TESTKEY', '7e0880be08d54de7a2572b3dd369b36a'
end

def test_base_uri
  ENV.fetch 'NEXOSIS_API_TESTURI', 'https://ml.nexosis.com/v1'
end

def test_client
  NexosisApi.client(api_key: test_api_key, base_uri: test_base_uri)
end

def handle_vcr(example)
  return run_with_http_interaction(example) if ENV['VCR_OFF']
  VCR.use_cassette(:cassette_name) { example.call }
end

def run_with_http_interaction(example)
  WebMock.allow_net_connect!
  VCR.turned_off(ignore_cassettes: true) { example.call }
  WebMock.disable_net_connect!
end