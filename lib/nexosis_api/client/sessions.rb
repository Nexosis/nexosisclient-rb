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
      # @raise [NexosisApi::HttpException]
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
      # @raise [NexosisApi::HttpException]
      # @raise [ArgumentError]
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
      # @raise [NexosisApi::HttpException]
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
        create_session(dataset_name, start_date, end_date, target_column, nil, 'forecast', result_interval, column_metadata)
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
        create_session(dataset_name, start_date, end_date, target_column, event_name, 'impact', result_interval, column_metadata)
      end

      # Get the results of the session.
      #
      # @param session_id [String] the Guid string returned in a previous session request
      # @param as_csv [Boolean] indicate whether results should be returned in csv format
      # @param prediction_interval [Float] one of the available prediction intervals for the session.
      # @return [NexosisApi::SessionResult] SessionResult if parsed, String of csv data otherwise
      # @raise [NexosisApi::HttpException]
      # @deprecated
      def get_session_results(session_id, as_csv = false, prediction_interval = nil)
        get_session_result_data(session_id, 0, 50, {as_csv: as_csv, prediction_interval: prediction_interval})
      end

      # Get the results of the session.
      #
      # @param session_id [String] the Guid string returned in a previous session request
      # @param page [Integer] optionally provide a page number for paging. Defaults to 0 (first page).
      # @param page_size [Integer] optionally provide a page size to limit the total number of results. Defaults to 50, max 1000
      # @param options [Hash] as_csv [Boolean] to indicate whether results should be returned in csv format; prediction_interval [Float] one of the available prediction intervals for the session.
      # @return [NexosisApi::SessionResult] SessionResult if parsed, String of csv data otherwise
      # @raise [NexosisApi::HttpException]
      # @since 2.1.0
      def get_session_result_data(session_id, page = 0, page_size = 50, options = {})
        session_result_url = "/sessions/#{session_id}/results"
        @headers['Accept'] = 'text/csv' if options[:as_csv]
        query = { 'page' => page, 'pageSize' => page_size }
        query.store('predictionInterval', options[:prediction_interval]) unless options[:prediction_interval].nil?
        response = self.class.get(session_result_url, headers: @headers, query: query)
        @headers.delete('Accept')
        if (response.success?)
          return response.body if options[:as_csv]
          NexosisApi::SessionResult.new(response.parsed_response)
        else
          raise HttpException.new("There was a problem getting the session: #{response.code}.", "get results for session #{session_id}" ,response)
        end
      end

      # Get a specific session by id.
      #
      # @param session_id [String] the Guid string returned in a previous session request
      # @return [NexosisApi::Session] a Session object populated with the session's data
      # @raise [NexosisApi::HttpException]
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
      # @param options [Hash] prediction_domain and or balance (true or false) indicator for classification
      # @return [NexosisApi::SessionResponse]
      # @raise [NexosisApi::HttpException]
      # @note - classifcation assumes balanced classes. The use of a 'balance=false' option
      # indicates that no attempt should be made to sample the classes in balanced fashion.
      # @since 1.3.0
      def create_model(datasource_name, target_column, columns = {}, options = { prediction_domain: 'regression' })
        model_url = '/sessions/model'
        body = {
          dataSourceName: datasource_name,
          targetColumn: target_column,
          predictionDomain: options[:prediction_domain].downcase
        }
        body.store(:extraParameters, { balance: options[:balance] }) if options.include?(:balance) && body[:predictionDomain] == 'classification'
        body.store(columns: columns) unless columns.empty?
        response = self.class.post(model_url, headers: @headers, body: body.to_json)
        if response.success?
          session_hash = { 'session' => response.parsed_response }.merge(response.headers)
          NexosisApi::SessionResponse.new(session_hash)
        else
          raise HttpException.new("There was a problem creating the model session: #{response.code}.", 'creating model session' ,response)
        end
      end

      # Create a new model based on a data source
      #
      # @param datasource_name [String] The datasource from which to build the model
      # @param columns [Hash] column metadata to modify roles, imputation, or target.
      # @param data_contains_anomalies [Boolean] Whether or not the source dataset contains anomalies (default is true)
      # @return [NexosisApi::SessionResponse]
      # @raise [NexosisApi::HttpException]
      # @since 2.1.0
      # @note The anomalies model session results will contain the anomalous observations when the session is complete.
      def create_anomalies_model(datasource_name, columns = {}, data_contains_anomalies = true)
        model_url = '/sessions/model'
        body = {
          dataSourceName: datasource_name,
          predictionDomain: 'anomalies',
          extraParameters: {
            'containsAnomalies': data_contains_anomalies
          },
          columns: columns
        }
        response = self.class.post(model_url, headers: @headers, body: body.to_json)
        raise HttpException.new("There was a problem creating the model session: #{response.code}.", 'creating anomaly model session' ,response) unless response.success?
        NexosisApi::SessionResponse.new(response.parsed_response.merge(response.headers))
      end

      # Create a new model based on a data source
      #
      # @param datasource_name [String] The datasource from which to build the model
      # @param target_column [String] The column which will be predicted when using the model
      # @param columns [Hash] column metadata to modify roles, imputation, or target.
      # @param balance [Boolean] Whether or not to balance classes during model building (default is true)
      # @return [NexosisApi::SessionResponse]
      # @raise [NexosisApi::HttpException]
      # @since 2.1.0
      # @note The anomalies model session results will contain the anomalous observations when the session is complete.
      def create_classification_model(datasource_name, target_column, columns = {}, balance = true)
        return create_model(datasource_name, target_column, columns, prediction_domain: 'classification', balance: balance)
      end

      # Get the confusion matrix for a completed classification session
      # @param session_id [String] The unique id of the completed classification session
      # @return [NexosisApi::ClassifierResult] a confusion matrix along with class labels and other session information.
      # @raise [NexosisApi::HttpException]
      # @since 1.4.1
      # @note - This endpoint returns a 404 for requests of non-classification sessions
      def get_confusion_matrix(session_id)
        result_url = "/sessions/#{session_id}/results/confusionmatrix"
        response = self.class.get(result_url, headers: @headers)
        raise HttpException.new("There was a problem getting a confusion matrix for session #{session_id}", 'getting confusion matrix', response) unless response.success?
        NexosisApi::ClassifierResult.new(response.parsed_response.merge(response.headers))
      end

      # Get the observation anomaly score for a completed anomalies session
      # @param session_id [String] The unique id of the completed anomalies session
      # @return [NexosisApi::ScoreResult] A session result with a list of each observation and score per column.
      # @raise [NexosisApi::HttpException]
      # @since 2.1.0
      # @note - This endpoint returns a 404 for requests of non-anomalies sessions
      def get_anomaly_scores(session_id, page = 0, page_size = 50)
        score_url = "/sessions/#{session_id}/results/anomalyScores"
        query = {
          page: page,
          pageSize: page_size
        }
        response = self.class.get(score_url, headers: @headers, query: query)
        raise HttpException.new("There was a problem getting the anomaly scores for session #{session_id}", 'getting anomaly scores', response) unless response.success?
        NexosisApi::AnomalyScores.new(response.parsed_response.merge(response.headers))
      end

      # Get the observation class score for a completed classification session
      # @param session_id [String] The unique id of the completed classification session
      # @param page_number [Integer] zero-based page number of results to retrieve
      # @param page_size [Integer] Count of results to retrieve in each page (max 1000).
      # @return [NexosisApi::ScoreResult] A session result with a list of each observation and score per column.
      # @raise [NexosisApi::HttpException]
      # @since 2.1.0
      # @note - This endpoint returns a 404 for requests of non-classification sessions
      def get_class_scores(session_id, page_number = 0, page_size = 50)
        score_url = "/sessions/#{session_id}/results/classScores"
        query = {
          page: page_number,
          pageSize: page_size
        }
        response = self.class.get(score_url, headers: @headers, query: query)
        raise HttpException.new("There was a problem getting the class scores for session #{session_id}", 'getting class scores', response) unless response.success?
        NexosisApi::ClassifierScores.new(response.parsed_response.merge(response.headers))
      end

      # Get a feature importance score for each column in the data source used in a session
      # @param session_id [String] The unique id of the completed session
      # @param page_number [Integer] zero-based page number of results to retrieve
      # @param page_size [Integer] Count of results to retrieve in each page (max 1000).
      # @return [NexosisApi::FeatureImportance]
      # @since 2.4.0
      # @note The score returned here is calculated before algorithm selection and so is not algorithm specific. For algorithms 
      # that can return internal scores you need to use the champion endpoints.
      # @note Those sessions which will provide scores have the supports_feature_importance attribute set True. Others will 404 at this endpoint.
      def get_feature_importance(session_id, page_number = 0, page_size = 50)
        importance_url = "/sessions/#{session_id}/results/featureimportance"
        query = {
          page: page_number,
          pageSize: page_size
        }
        response = self.class.get(importance_url, headers: @headers, query: query)
        raise HttpException.new("There was a problem getting the feature importance scores for session #{session_id}", 'getting feature importance', response) unless response.success?
        NexosisApi::FeatureImportance.new(response.parsed_response.merge(response.headers))
      end

      # Get per result distance metric for anomaly detection sessions.
      # @param session_id [String] The unique id of the completed session
      # @param page_number [Integer] zero-based page number of results to retrieve
      # @param page_size [Integer] Count of results to retrieve in each page (max 1000).
      # @return [NexosisApi::AnomalyDistances]
      # @since 2.4.0
      # @note This method will return 404 when the session for the given session id does not have a prediction domain of 'anomalies'
      # @see https://en.wikipedia.org/wiki/Mahalanobis_distance
      def get_distance_metrics(session_id, page_number = 0, page_size = 50)
        distance_url = "/sessions/#{session_id}/results/mahalanobisdistances"
        query = {
          page: page_number,
          pageSize: page_size
        }
        response = self.class.get(distance_url, headers: @headers, query: query)
        raise HttpException.new("There was a problem getting the distance metrics for session #{session_id}", 'getting distance metrics', response) unless response.success?
        NexosisApi::AnomalyDistances.new(response.parsed_response.merge(response.headers))
      end

      private

      # @private
      def create_session(dataset_name, start_date, end_date, target_column = nil, event_name = nil, type = 'forecast', result_interval = NexosisApi::TimeInterval::DAY, column_metadata = nil)
        session_url = "/sessions/#{type}"
        query = {
          'targetColumn' => target_column.to_s,
          'startDate' => start_date.to_s,
          'endDate' => end_date.to_s,
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
          raise HttpException.new("Unable to create new #{type} session", "Create session for dataset #{dataset_name}", response)
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
