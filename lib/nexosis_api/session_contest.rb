module NexosisApi
  # Class to parse the algorithm contestants from a session
  # @since 2.0.0
  class SessionContest < Session
    def initialize(data_hash)
      data_hash.each do |k, v|
        if k == 'champion'
          instance_variable_set("@#{k}", NexosisApi::AlgorithmRun.new(v))
        elsif k == 'contestants'
          contestant_array = []
          v.each { |c| contestant_array << NexosisApi::AlgorithmRun.new(c) }
          instance_variable_set("@#{k}", contestant_array)
        end
      end
      super(data_hash.reject { |key, _v| key == 'champion' || key == 'contestants' })
    end

    # The champion algorithm used
    # @return [NexosisApi::AlgorithmContestant]
    attr_accessor :champion

    # All other algorithms which competed
    # @return [Array of NexosisApi::AlgorithmContestant]
    attr_accessor :contestants
  end
end
