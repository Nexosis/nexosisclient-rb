module NexosisApi
    #Class to parse the model data results from a session 
    class AlgorithmSelection
        def initialize(dataHash)
           dataHash.each do |k,v|
               if k == "champion"
                   instance_variable_set("@#{k}", NexosisApi::AlgorithmRun.new(v))
               elsif k == "contestants"
                    @contestantArray = Array.new
                    v.each {|c| @contestantArray << NexosisApi::AlgorithmRun.new(c)}
                    instance_variable_set("@#{k}", @contestantArray)
               else
                  instance_variable_set("@#{k}", v) unless v.nil?    
               end
           end
        end

        # The date on which this algo was selected as champion
        # @return [DateTime]
        attr_accessor :date
        
        # The session which selected the algorithm
        # @return [String] session identifier
        attr_accessor :sessionId

        # The champion algorithm used
        # @return [NexosisApi::AlgorithmRun]
        attr_accessor :champion

        # All other algorithms which competed
        # @return [Array of NexosisApi::AlgorithmRun]
        attr_accessor :contestants
    end
end
