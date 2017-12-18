module NexosisApi
  # Class to parse the algorithm contestants from a session
  # @since 2.0.0
  class SessionContest < Session
    def initialize(contest_hash)
      contest_hash.each do |k, v|
        if k.to_s == 'champion'
          instance_variable_set("@#{k}", NexosisApi::AlgorithmContestant.new(v))
        elsif k.to_s == 'contestants'
          instance_variable_set("@#{k}", v.map { |c| NexosisApi::AlgorithmContestant.new(c) })
        elsif k.to_s == 'championMetric'
          @champion_metric = v
        end
      end
      super(contest_hash.reject { |key, _v| key == 'champion' || key == 'contestants' })
    end

    # The champion algorithm used
    # @return [NexosisApi::AlgorithmContestant]
    attr_accessor :champion

    # All other algorithms which competed
    # @return [Array of NexosisApi::AlgorithmContestant]
    attr_accessor :contestants

    # Name of metric used to determine champion algorithm
    # @return [String] metric name
    attr_accessor :champion_metric
  end
end
