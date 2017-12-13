module NexosisApi
  # Class to parse the session selection metrics from a particular session
  # @since 2.0.0
  class SessionSelectionMetrics < Session
    def intialize(metrics_hash)
      if !metrics_hash['metricSets'].nil? && !metrics_hash['metricSets'].empty
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