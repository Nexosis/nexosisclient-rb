module NexosisApi
    # Class to parse the metric results of an impact analysis
    class ImpactMetric
        def initialize(metricHash)
           metricHash.each do |k,v|
               instance_variable_set("@#{k}", v) unless v.nil?
           end
        end

        # Statistical value used to determine the significance of the impact.
        # @return [Float]
        attr_accessor :pValue

        # Total absolute effect of the event on the dataset.
        # @return [Float]
        attr_accessor :absoluteEffect

        # Percentage impact of the event on the dataset.
        # @return [Float]
        attr_accessor :relativeEffect
    end
end