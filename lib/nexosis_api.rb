require 'httparty'
require 'nexosis_api/client'

# The container for the Nexosis API Client
module NexosisApi
  class << self
    def client options = {}
      return @client if defined?(@client)
      @client = NexosisApi::Client.new(options)
    end
  end
end