require 'csv'
require 'json'

module NexosisApi
  class Client
    # Session-based API operations
    #
    # @see http://docs.nexosis.com/
    module Sessions

      # List sessions previously submitted
      #
      # @param query_options [Hash] optionally provide query parameters to limit the search of sessions. 
      # @param page [Integer] optionally provide a page number for paging. Defaults to 0 (first page).
      # @param pageSize [Integer] optionally provide a page size to limit the total number of results. Defaults to 50, max 1000
      # @return [NexosisApi::PagedArray of NexosisApi::SessionResponse] with all sessions matching the query or all if no query
      # @note query parameters hash members are dataset_name, event_name, requested_before_date, and requested_after_date. 
      #    After and before dates refer to the session requested date.
      # @example query for just one dataset
      #   sessions = NexosisApi.client.list_sessions :dataset_name => 'MyDataset'
      def list_sessions(query_options = {}, page = 0, pageSize = 50)
        sessions_url = '/sessions'
        query = {
          'dataSetName' => query_options[:dataset_name],
          'eventName' => query_options[:event_name],
          'requestedAfterDate' => query_options[:requested_after_date],
          'requestedBeforeDate' => query_options[:requested_before_date],
          'type' => query_options[:type],
          'page' => page,
          'pageSize' => pageSize
        }
        response = self.class.get(sessions_url, headers: @headers, query: query)
        raise HttpException.new('Could not retrieve sessions',
                                "Get all sessions with query #{query_options}",
                                response) unless response.success?
        NexosisApi::PagedArray.new(response.parsed_response, response.parsed_response['items'].map do |session_hash|
          response_hash = { 'session' => session_hash }.merge(response.headers)
          NexosisApi::SessionResponse.new(response_hash)
        end)
      end

      # Remove a session
      # @param session_id [String] required session identifier
      def remove_session(session_id)
        if (session_id.to_s.empty?)
          raise ArgumentError 'session_id cannot be empty or nil'
        end
        session_url = "/sessions/#{session_id}"
        response = self.class.delete(session_url, headers: @headers)
        return if response.success?
        raise HttpException.new('Could not delete session with given id', "remove session with id #{session_id}", response)
      end

      # Remove sessions that have been run. All query options are optional and will be used to limit the sessions removed.
      # @param query_options [Hash] optionally provide query parametes to limit the set of sessions removed.
      # @note query parameters hash members are type, dataset_name, event_name, start_date, and end_date.
      #    Start and end dates refer to the session requested date.
      #    Results are not removed but then can only be accessed by dataset name
      # @example Remove all sessions based on a dataset by name
      #    NexosisApi.client.remove_sessions :dataset_name => 'existing_dataset'
      def remove_sessions(query_options = {})
        sessions_url = '/sessions'
        response = self.class.delete(sessions_url, :headers => @headers, :query => get_query_from_options(query_options))
        return if response.success?
        raise HttpException.new('Could not remove sessions', "Remove sessions with query #{query_options.to_s}",response)
      end

      # Initiate a new forecast session based on a named dataset.
      #
      # @param dataset_name [String] The name of the saved data set that has the data to forecast on.
      # @param start_date [DateTime] The starting date of the forecast period. Can be ISO 8601 string.
      # @param end_date [DateTime] The ending date of the forecast period. Can be ISO 8601 string.
      # @param target_column [String] The name of the column for which you want predictions. Nil if defined in dataset.
      # @param result_interval [NexosisApi::TimeInterval] (optional) - The date/time interval (e.g. Day, Hour) at which predictions should be generated. So, if Hour is specified for this parameter you will get a Result record for each hour between startDate and endDate. If unspecified, we’ll generate predictions at a Day interval.
      # @param column_metadata [Array of NexosisApi::Column] (optional) - specification for how to handle columns if different from existing metadata on dataset
      # @return [NexosisApi::SessionResponse] providing information about the sesssion
      # @note The time interval selected must be greater than or equal to the finest granularity of the data provided.
      #    For instance if your data includes many recoreds per hour, then you could request hour, day, or any other result interval.
      #    However, if your data includes only a few records per day or fewer, then a request for an hourly result interval will produce poor results.
      def create_forecast_session(dataset_name, start_date, end_date, target_column = nil, result_interval = NexosisApi::TimeInterval::DAY, column_metadata = nil)
        create_session(dataset_name, start_date, end_date, target_column, false, nil, 'forecast', result_interval, column_metadata)
      end

      # Estimate the cost of a forecast from data already saved to the API.
      #
      # @param dataset_name [String] The name of the saved data set that has the data to forecast on.
      # @param start_date [DateTime] The starting date of the forecast period. Can be ISO 8601 string. 
      # @param end_date [DateTime] The ending date of the forecast period. Can be ISO 8601 string.
      # @param target_column [String] The name of the column for which you want predictions. Nil if defined in dataset.
      # @param result_interval [NexosisApi::TimeInterval] (optional) - The date/time interval (e.g. Day, Hour) at which predictions should be generated. So, if Hour is specified for this parameter you will get a Result record for each hour between startDate and endDate. If unspecified, we’ll generate predictions at a Day interval.
      # @return [NexosisApi::SessionResponse] providing information about the sesssion, including the cost
      def estimate_forecast_session(dataset_name, start_date, end_date, target_column = nil, result_interval = NexosisApi::TimeInterval::DAY)
        create_session(dataset_name, start_date, end_date, target_column, true, nil, 'forecast', result_interval)
      end

      # Analyze impact for an event with data already saved to the API.
      #
      # @param dataset_name [String] The name of the saved data set that has the data to forecast on.
      # @param start_date [DateTime] The starting date of the impactful event. Can be ISO 8601 string. 
      # @param end_date [DateTime] The ending date of the impactful event. Can be ISO 8601 string.
      # @param event_name [String] The name of the event.
      # @param target_column [String] The name of the column for which you want predictions. Nil if defined in datatset.
      # @param result_interval [NexosisApi::TimeInterval] (optional) - The date/time interval (e.g. Day, Hour) at which predictions should be generated. So, if Hour is specified for this parameter you will get a Result record for each hour between startDate and endDate. If unspecified, we’ll generate predictions at a Day interval.
      # @param column_metadata [Array of NexosisApi::Column] (optional) - specification for how to handle columns if different from existing metadata on dataset 
      # @return [NexosisApi::SessionResponse] providing information about the sesssion
      def create_impact_session(dataset_name, start_date, end_date, event_name, target_column = nil, result_interval = NexosisApi::TimeInterval::DAY, column_metadata = nil)
        create_session(dataset_name, start_date, end_date, target_column, false, event_name, 'impact', result_interval, column_metadata)
      end

      # Estimate the cost of impact analysis for an event with data already saved to the API.
      #
      # @param dataset_name [String] The name of the saved data set that has the data to forecast on.
      # @param start_date [DateTime] The starting date of the impactful event. Can be ISO 8601 string. 
      # @param end_date [DateTime] The ending date of the impactful event. Can be ISO 8601 string.
      # @param event_name [String] The name of the event.
      # @param target_column [String] The name of the column for which you want predictions. Nil if defined in dataset.
      # @param result_interval [NexosisApi::TimeInterval] (optional) - The date/time interval (e.g. Day, Hour) at which predictions should be generated. So, if Hour is specified for this parameter you will get a Result record for each hour between startDate and endDate. If unspecified, we’ll generate predictions at a Day interval.
      # @return [NexosisApi::SessionResponse] providing information about the sesssion, including the cost
      def estimate_impact_session(dataset_name, start_date, end_date, event_name, target_column = nil, result_interval = NexosisApi::TimeInterval::DAY)
        create_session(dataset_name, start_date, end_date, target_column, true, event_name, 'impact', result_interval)
      end

      # Get the results of the session.
      #
      # @param session_id [String] the Guid string returned in a previous session request
      # @param as_csv [Boolean] indicate whether results should be returned in csv format
      # @return [NexosisApi::SessionResult] SessionResult if parsed, String of csv data otherwise
      def get_session_results(session_id, as_csv = false)
        session_result_url = "/sessions/#{session_id}/results"
        @headers['Accept'] = 'text/csv' if as_csv
        response = self.class.get(session_result_url, @options)
        @headers.delete('Accept')

        if (response.success?)
          return response.body if as_csv
          NexosisApi::SessionResult.new(response.parsed_response)
        else
          raise HttpException.new("There was a problem getting the session: #{response.code}.", "get results for session #{session_id}" ,response)
        end
      end

      # Get a specific session by id.
      #
      # @param session_id [String] the Guid string returned in a previous session request
      # @return [NexosisApi::Session] a Session object populated with the session's data
      def get_session(session_id)
        session_url = "/sessions/#{session_id}"
        response = self.class.get(session_url, @options)
        return NexosisApi::Session.new(response.parsed_response) if response.success?
        raise HttpException.new("There was a problem getting the session: #{response.code}.", "getting session #{session_id}" ,response)
      end

      # Create a new model based on a data source
      #
      # @param datasource_name [String] The datasource from which to build the model
      # @param target_column [String] The column which will be predicted when using the model
      # @param columns [Hash] column metadata to modify roles, imputation, or target.
      # @since 1.3.0
      def create_model(datasource_name, target_column, columns = {})
        model_url = '/sessions/model'
        body = {
          dataSourceName: datasource_name,
          targetColumn: target_column,
          predictionDomain: 'regression',
          isEstimate: false
        }
        body.store(columns: columns) unless columns.empty?
        response = self.class.post(model_url, headers: @headers, body: body.to_json)
        if response.success?
          session_hash = { 'session' => response.parsed_response }.merge(response.headers)
          NexosisApi::SessionResponse.new(session_hash)
        else
          raise HttpException.new("There was a problem creating the model session: #{response.code}.", 'creating model session' ,response)
        end
      end

      private

      # @private
      def create_session(dataset_name, start_date, end_date, target_column = nil, is_estimate=false, event_name = nil, type = 'forecast', result_interval = NexosisApi::TimeInterval::DAY, column_metadata = nil)
        session_url = "/sessions/#{type}"
        query = {
          'targetColumn' => target_column.to_s,
          'startDate' => start_date.to_s,
          'endDate' => end_date.to_s,
          'isestimate' => is_estimate.to_s,
          'resultInterval' => result_interval.to_s
        }
        query['dataSetName'] = dataset_name.to_s unless dataset_name.to_s.empty?
        if (event_name.nil? == false)
          query['eventName'] = event_name
        end
        body = ''
        if (column_metadata.nil? == false)
          column_json = Column.to_json(column_metadata)
          body = {
            'dataSetName' => dataset_name,
            'columns' => column_json
          }
        end
        response = self.class.post(session_url, headers: @headers, query: query, body: body.to_json)
        if (response.success?)
          session_hash = { 'session' => response.parsed_response }.merge(response.headers)
          NexosisApi::SessionResponse.new(session_hash)
        else
          raise HttpException.new("Unable to create new #{type} session", "Create session for dataset #{dataset_name}",response)
        end
      end

      def get_query_from_options(options)
        query = {
          'dataSetName' => options[:dataset_name],
          'eventName' => options[:event_name],
          'startDate' => options[:start_date],
          'endDate' => options[:end_date],
          'type' => options[:type]
        }
        query
      end
    end
  end
end
