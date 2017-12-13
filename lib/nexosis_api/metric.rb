module NexosisApi
  # Class to parse algorithm metrics from model results
  class Metric
    def initialize(name, value)
      @name = name
      @value = value
    end

    # Friendly name of the metric
    # @return [String]
    attr_accessor :name

    # Calculated metric
    # @return [Float]
    attr_accessor :value
  end
end