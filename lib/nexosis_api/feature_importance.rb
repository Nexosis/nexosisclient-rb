module NexosisApi
  # Class to hold the parse results of a request for Feature Importance scores
  # @since 2.4.0
  class FeatureImportance < SessionResponse
    def initialize(session_hash)
      @scores = session_hash.fetch(:featureImportance) { |k| session_hash.fetch(k.to_s) }
      super(session_hash.reject { |k, _v| k.to_s.casecmp('featureimportance').zero? })
    end

    attr_reader :scores
  end
end
