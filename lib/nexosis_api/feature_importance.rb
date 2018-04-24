module NexosisApi
  # Class to hold the parse results of a request for Feature Importance scores
  # @since 2.4.0
  class FeatureImportance < SessionResponse
    def initialize(session_hash)
      @scores = NexosisApi::PagedArray.new(session_hash, session_hash.fetch(:featureImportance) { |k| session_hash.fetch(k.to_s) }.to_a.map{|i| { i[0] => i[1] } })
      super(session_hash.reject { |k, _v| k.to_s.casecmp('featureimportance').zero? })
    end

    # A paged array of scores where each element of the array is a hash of {feature: score}
    # @return NexosisApi::PagedArray
    attr_reader :scores
  end
end
