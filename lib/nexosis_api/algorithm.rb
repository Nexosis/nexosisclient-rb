module NexosisApi
  # Class to parse an individual algorithm
  class Algorithm
    def initialize(algo_hash)
      algo_hash.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # A friendly name for the algorithm
    # @return [String]
    attr_accessor :name

    # Descriptive explanation of the algorithm implementation
    # @return [String]
    attr_accessor :description
  end
end
