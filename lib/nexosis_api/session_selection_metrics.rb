module NexosisApi
  # Class to parse the session selection metrics from a particular session
  # @since 2.0.0
  class SessionSelectionMetrics < Session
    def initialize(metrics_hash)
      if !metrics_hash['metricSets'].nil?
        @dataset_properties = metrics_hash['metricSets'][0]['dataSetProperties'] unless metrics_hash['metricSets'][0]['dataSetProperties'].nil?
        @metrics = metrics_hash['metricSets'][0]['metrics'] unless metrics_hash['metricSets'][0]['metrics'].nil?
      end
      super(metrics_hash.reject { |k, _v| k == 'metricSets' })
    end

    # transformations performed on dataset prior to algorithm run
    # @return [Array] string list of transformations
    attr_reader :dataset_properties

    # dataset metrics describing some properties of it
    # @return [Hash] name value pairs of dataset metrics
    attr_reader :metrics
  end
end