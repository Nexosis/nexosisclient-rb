require 'nexosis_api/session_response'
module NexosisApi
  # class to hold the parsed results of an anomalyScores request
  # @since 2.0.1
  class AnomalyScores < SessionResponse
    def initialize(result_hash)
      @data = NexosisApi::PagedArray.new(result_hash, result_hash['data'])
      @percent_anomalies = result_hash['metrics']['percentAnomalies'] unless result_hash['metrics'].nil?
      super(result_hash.reject { |k, _v| k.to_s == 'data' || k.to_s == 'metrics' })
    end

    # The anomalies found while building your model.
    # @return [NexosisApi::PagedArray] per observation feature scores of the form {"target_col": "0.3882", "col_1" : "0.828", "target_col:actual" : "0.402"} 
    attr_reader :data

    # The percent of observations found to be anomalous in the training data set
    attr_reader :percent_anomalies
  end
end