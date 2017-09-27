require 'nexosis_api/algorithm_run'
require 'nexosis_api/algorithm_selection'
require 'nexosis_api/algorithm'
require 'nexosis_api/calendar_jointarget'
require 'nexosis_api/column'
require 'nexosis_api/column_options'
require 'nexosis_api/column_role'
require 'nexosis_api/column_type'
require 'nexosis_api/dataset_data'
require 'nexosis_api/dataset_jointarget'
require 'nexosis_api/dataset_model'
require 'nexosis_api/dataset_summary'
require 'nexosis_api/http_exception'
require 'nexosis_api/impact_metric'
require 'nexosis_api/imports_response'
require 'nexosis_api/join'
require 'nexosis_api/link'
require 'nexosis_api/metric'
require 'nexosis_api/model_summary'
require 'nexosis_api/session_response'
require 'nexosis_api/session_result'
require 'nexosis_api/session'
require 'nexosis_api/time_interval'
require 'nexosis_api/view_definition'
require 'nexosis_api/view_data'
require 'nexosis_api/client/sessions'
require 'nexosis_api/client/datasets'
require 'nexosis_api/client/imports'
require 'nexosis_api/client/views'
require 'nexosis_api/client/models'

module NexosisApi
  # Primary entry point to working with Nexosis API
  class Client
    include HTTParty
    base_uri 'https://ml.nexosis.com/v1'
    include Client::Sessions
    include Client::Datasets
    include Client::Imports
    include Client::Views

    def initialize(options = {})
      raise ArgumentError, 'api_key was not defined' unless options[:api_key].nil? == false
      @api_key = options[:api_key]
      self.class.base_uri options[:base_uri] unless options[:base_uri].nil?
      @headers = { 'api-key' => @api_key, 'Content-Type' => 'application/json',
                   'User-Agent' => 'Nexosis-Ruby-API-Client/1.2' }
      @options = { headers: @headers, format: :json }
    end

    # Gets the current account balance.
    #
    # @return [String] a string with the numeric balance and currency identifier postfix - 10.0 USD
    # @example Get account balance
    #   client.get_account_balance
    def get_account_balance()
      session_url = '/sessions'
      response = self.class.get(session_url, @options)
      response.headers['nexosis-account-balance']
    end

    private

    # @private
    def process_csv_to_s csv
      content = ''
      if(csv.is_a?(CSV))
        csv.each do |row|
          if(csv.headers.nil?)
            # not using row.to_csv because it uses non-compliant '\n' newline
            content.concat(row.join(',')).concat("\r\n")
          else
            content.concat(row.fields.join(',')).concat("\r\n")
          end
        end
        if(csv.headers.nil? == false)
          content.prepend(csv.headers.join(',').concat("\r\n")) unless csv.headers.nil?
        end
      else
        content = csv
      end
      content
    end

    # @private
    def create_query(page_number, page_size, options = {})
      options.store(:page_number, page_number)
      options.store(:page_size, page_size)
      query = {
        'page' => [page_number],
        'pageSize' => [page_size]
      }
      query['startDate'] = [options[:start_date].iso8601.gsub(/\+/,'%2B')] unless options[:start_date].nil?
      query['endDate'] = [options[:end_date].iso8601.gsub(/\+/,'%2B')] unless options[:end_date].nil?
      query['include'] = options[:include] unless options[:include].nil?
      query
    end

    def array_query_normalizer(query_set)
      query_set.map { |key, value| value.map { |v| "#{key}=#{v}" } }.join('&')
    end
  end
end
