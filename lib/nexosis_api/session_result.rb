module NexosisApi
  # Class for parsing the results of a completed session
  class SessionResult < Session
    def initialize(session_hash)
      session_hash.each do |k, v|
        if k == 'metrics'
          instance_variable_set("@#{k}", NexosisApi::ImpactMetric.new(v)) unless v.nil?
        else
          instance_variable_set("@#{k}", v) unless v.nil?
        end
      end
      super(session_hash.reject { |k, v| k == 'data' || k == 'metrics' })
    end

    # The impact analysis if this session type is impact
    # @return [NexosisApi::ImpactMetric]
    attr_accessor :metrics

    # The result data in a hash with the name of the target column
    # @return [Hash]
    attr_accessor :data
  end
end
