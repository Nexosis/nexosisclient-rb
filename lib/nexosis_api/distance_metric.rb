module NexosisApi
  # Class to hold the parse results of each 'row' in distance metric response
  # @since 2.4.0
  class DistanceMetric
    def initialize(metric_hash)
      failover = ->(k) { metric_hash.fetch(k.to_s) }
      @anomaly_score = metric_hash.fetch(:anomaly, &failover).to_f
      @distance = metric_hash.fetch(:mahalanobis_distance, &failover).to_f
      @data = metric_hash.reject { |k, _v| (k.to_s.casecmp? 'mahalanobis_distance') || (k.to_s.casecmp? 'anomaly') }
    end

    # The anomaly score determining if this entry is an anomaly
    # @return [Float]
    attr_reader :anomaly_score

    # The calculated distance for this row of values
    # @return [Float]
    attr_reader :distance

    # The set of values in this row
    # @return [Hash]
    attr_reader :data
  end
end
