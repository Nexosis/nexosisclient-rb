require 'nexosis_api/session_response'
module NexosisApi
  # class to hold parsed results of distance metric request
  # @since 2.4.0
  class AnomalyDistances < SessionResponse
    def initialize(distance_data)
      data = distance_data.fetch(:data) { |k| distance_data.fetch(k.to_s) }
      @data = NexosisApi::PagedArray.new(distance_data, data.map { |v| NexosisApi::DistanceMetric.new(v) })
      super(distance_data.reject { |k, _v| k.to_s.casecmp? 'data' })
    end

    # array of metrics providing the distance along with standard anomaly result
    # @return [NexosisApi::PagedArray NexosisApi::DistanceMetric] - each anomaly score, distance, and the row values
    attr_reader :data
  end
end
