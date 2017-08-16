module NexosisApi
  # Class to parse results of an algorithm run
  class AlgorithmRun
    def initialize(run_hash)
      run_hash.each do |k, v|
        if k == 'metrics'
          metric_set = []
          v.each { |m| metric_set << NexosisApi::Metric.new(m) unless m.nil? }
          instance_variable_set("@#{k}", metric_set)
        elsif k == 'links'
          link_set = []
          v.each { |l| link_set << NexosisApi::Link.new(l) unless l.nil? }
          instance_variable_set("@#{k}", link_set)
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
