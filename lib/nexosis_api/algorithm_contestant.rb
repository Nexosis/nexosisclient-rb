module NexosisApi
  # Class to parse results of an algorithm run
  # @since 2.0.0
  class AlgorithmContestant
    def initialize(contestant_hash)
      contestant_hash.each do |k, v|
        if k.to_s == 'links'
          instance_variable_set("@#{k}", v.map { |l| NexosisApi::Link.new(l) unless l.nil? })
        elsif k.to_s == 'dataSourceProperties'
          @datasource_properties = v
        elsif k.to_s == 'algorithm'
          instance_variable_set("@#{k}", NexosisApi::Algorithm.new(v)) unless v.nil?
        else
          instance_variable_set("@#{k}", v)
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

    # The test dataset used to score the algo
    # @return [Array of Hash] columnname: value hash of each observation row in test set
    # @note - may be nil when reviewing contestant lists
    attr_reader :data
  end
end
