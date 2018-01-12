module NexosisApi
  # Class for parsing the results of a session based request
  class Session
    def initialize(session_hash)
      val_map = { 'resultInterval' => :@result_interval,
                  'dataSourceName' => :@datasource_name,
                  'modelId' => :@model_id,
                  'sessionId' => :@session_id,
                  'availablePredictionIntervals' => :@prediction_intervals,
                  'startDate' => :@start_date,
                  'endDate' => :@end_date,
                  'predictionDomain' => :@prediction_domain,
                  'extraParameters' => :@extra_parameters,
                  'targetColumn' => :@target_column,
                  'statusHistory' => :@status_history }
      session_hash.each do |k, v|
        if (k == 'links')
          @links = v.map { |l| NexosisApi::Link.new(l) }
        elsif (k == 'columns')
          @column_metadata = v.reject { |_key, value| value.nil? }
                              .map do |col_key, col_val|
                                NexosisApi::Column.new(col_key, v[col_key])
                              end
        elsif (k == 'requestedDate')
          @requested_date = DateTime.parse(v)
        elsif (k == 'messages')
          @messages = v.map { |m| NexosisApi::Message.new(m) } unless v.empty?
        else
          begin
            instance_variable_set("@#{k}", v) unless v.nil?
          rescue
            # header value not set - exception swallowed.
          end
        end
        instance_variable_set(val_map[k.to_s], v) unless val_map[k.to_s].nil?
      end
    end

    # identifier for this sesssion
    # @return [String]
    # @since 1.4.0
    attr_accessor :session_id

    # What type of analysis was run during this session
    # @return [String]
    attr_accessor :type

    # Is this session requested, started, or completed
    # @return [String]
    attr_accessor :status

    # Date and status of each status this session has entered
    # @return [Array of Hash]
    # @note - each status object in array is form { date: 'date', status: 'status' }
    attr_accessor :status_history

    # reserved for future extensions
    # @return [Hash]
    # @note - included 'balance' parameter for classification models
    attr_accessor :extra_parameters

    # The column in the dataset for which this session ran predictions
    # @return [String]
    attr_accessor :target_column

    # The start date of analysis in this session
    # @return [DateTime]
    # @since 1.4.0
    attr_accessor :start_date
    
    # The end date of analysis in this session
    # @return [DateTime]
    # @since 1.4.0
    attr_accessor :end_date
    
    # associated hypermedia
    # @return [Array of NexosisApi::Link]
    attr_accessor :links

    # The column descriptors for the data in this session
    #    will reflect either the metadata sent in, defaults form dataset, or inferred values
    # @return[Array of NexosisApi::Column]
    attr_accessor :column_metadata

    # The requested result interval. Default is DAY if none was requested during session creation.
    # @return [NexosisApi::TimeInterval]
    attr_accessor :result_interval

    # The name of the datasource used to run this session
    # @return [String] - the dataset or view name
    # @since 1.2.0
    attr_accessor :datasource_name

    # The date this session was orginally submitted
    # @since 1.3.0
    attr_accessor :requested_date

    # The id of the model created by this session if any
    # @return [String] a uuid/buid format unique string for the model
    # @since 1.3.0
    # @note This is always empty in time-series sessions (forecast/impact)
    # The model id returned here should be used in all future calls
    # to model endpoints - primarily the /models/{model_id}/predict endpoint.
    attr_accessor :model_id

    # An array of the prediction intervals available for this session's results
    # @return [Array]
    # @note - by default the .5 interval will be returned in results. Consult
    #    this list for other intervals which can be requested.
    # @since 1.4.0
    attr_accessor :prediction_intervals

    # The type of model if a model creation session
    # @return [String]
    # @since 1.4.1
    attr_accessor :prediction_domain

    # A list of warning or error messages optionally returned from session
    # @return [Array of Message]
    attr_accessor :messages
  end
end
