module NexosisApi
  # Class for parsing the results of a completed session
  class SessionResult < Session
    def initialize(session_hash)
      session_hash.each do |k, v|
        if k.to_s == 'metrics' && session_hash['type'] == 'impact'
          instance_variable_set("@#{k}", NexosisApi::ImpactMetric.new(v)) unless v.nil?
        elsif k.to_s == 'metrics'
          @metrics = v.map { |key, value| NexosisApi::Metric.new( { 'name' => key.to_s, 'value' => value } ) } unless v.nil?
        elsif k.to_s == 'data'
          @data = v
        end
      end
      super(session_hash.reject { |k, _v| k.to_s == 'data' || k.to_s == 'metrics' })
    end

    # The impact analysis if this session type is impact
    # @return [NexosisApi::ImpactMetric]
    attr_accessor :metrics

    # The result data in a hash with the name of the target column
    # @return [Array of Hash]
    # @note When retrieving a model creation session this field
    # will contain the test data and results.
    attr_accessor :data
  end
end
