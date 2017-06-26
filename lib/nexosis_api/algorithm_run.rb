module NexosisApi
    # Class to parse results of an algorithm run
    class AlgorithmRun
        def initialize(runHash)
           runHash.each do |k,v|
               if k == "metrics"
                   @metricSet = Array.new
                   v.each{|m| @metricSet << NexosisApi::Metric.new(m) unless m.nil?}
                   instance_variable_set("@#{k}", @metricSet)
               elsif k == "links"
                   @linkSet = Array.new
                   v.each{|l| @linkSet << NexosisApi::Link.new(l) unless l.nil?}
                   instance_variable_set("@#{k}", @linkSet)
               else
                    instance_variable_set("@#{k}", NexosisApi::Algorithm.new(v)) unless v.nil?
               end
           end
        end

        # Identifier of algorithm run
        # @return [NexosisApi::Algorithm] 
        attr_accessor :algorithm        
        
        # Set of {NexosisApi::Metric} on algorithm
        # @return [Array]
        attr_accessor :metrics
        
        # Relevant hypermedia as {NexosisApi::Link}
        # @return [Array]
        attr_accessor :links
    end
end
