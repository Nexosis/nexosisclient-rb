module NexosisApi
  # Class to hold the parse results of an outlier response
  # @note When Nexosis runs a time-series forecast, a smoothed dataset is created in addition
  # to the original. These outlier values represent those which were modified in that smoothed
  # dataset.
  # @since 2.4.0
  class TimeseriesOutliers < SessionResponse
    def initialize(outlier_hash)
      data = outlier_hash.fetch(:data) { |k| outlier_hash.fetch(k.to_s) }
      @data = NexosisApi::PagedArray.new(outlier_hash, data.map { |v| NexosisApi::Outlier.new(v) })
      super(outlier_hash.reject { |k, _v| k.to_s.casecmp? 'data' })
    end

    # The set of outlier values found in the given sessions dataset
    # @return [NexosisApi::PagedArray NexosisApi::Outlier]
    attr_reader :data
  end
end
