module NexosisApi
  # Class to hold the parse results of an individual outlier for time-series
  # @note When Nexosis runs a time-series forecast, a smoothed dataset is created in addition to the original. These outlier values represent those which were modified in that smoothed dataset.
  # @since 2.4.0
  class Outlier
    def initialize(outlier_hash)
      match_smooth = ->(k, _v) { !k.match(/:smooth/).nil? }
      match_actual = ->(k, _v) { !k.match(/:actual/).nil? }
      @timestamp = DateTime.parse(outlier_hash.fetch(:timeStamp) { |k| outlier_hash.fetch(k.to_s) })
      @smoothed = outlier_hash.select(&match_smooth).first[1].to_f if outlier_hash.any? &match_smooth
      @actual = outlier_hash.select(&match_actual).first[1].to_f if outlier_hash.any? &match_actual
    end

    # Record timestamp for the given target values
    # @return [DateTime]
    attr_reader :timestamp

    # The original value for this target
    # @return [Float]
    attr_reader :actual

    # The smoothed target used in the smoothed data set
    # @return [Float]
    attr_reader :smoothed
  end
end
