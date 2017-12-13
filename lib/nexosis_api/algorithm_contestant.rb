module NexosisApi
  # Class to parse results of an algorithm run
  # @since 2.0.0
  class AlgorithmContestant
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
        elsif k == 'dataSourceProperties'
          @datasource_properties = v
        else
          instance_variable_set("@#{k}", NexosisApi::Algorithm.new(v)) unless v.nil?
        end
      end
    end

    # Unique identifier for this contestant
    attr_reader :id

    # Identifier of algorithm run
    # @return [NexosisApi::Algorithm]
    attr_accessor :algorithm        

    # Name and value for metrics calculated for this algorithm
    # @return [Hash]
    attr_accessor :metrics

    # Relevant hypermedia as {NexosisApi::Link}
    # @return [Array]
    attr_accessor :links

    # Operations performed on datasource prior to run
    # @return [Array]
    attr_reader :datasource_properties

  end
end
