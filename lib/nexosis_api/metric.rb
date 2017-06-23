module NexosisApi
    # Class to parse algorithm metrics from model results
    class Metric
        def initialize(metricHash)
           metricHash.each do |k,v|
               instance_variable_set("@#{k}", v) unless v.nil?
           end
        end

        # Friendly name of the metric
        # @return [String]
        attr_accessor :name

        # Identifier for metric type
        # @return [String]
        attr_accessor :code

        # Calculated metric
        # @return [Float]
        attr_accessor :value
    end
end