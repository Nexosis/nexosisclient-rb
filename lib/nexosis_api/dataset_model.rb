module NexosisApi
    # Class to parse the model results calculated for a dataset
    class DatasetModel
        def initialize(dataHash)
           dataHash.each do |k,v|
               if k == "championContest"
                    instance_variable_set("@#{k}", NexosisApi::AlgorithmSelection.new(v))
               else
                    instance_variable_set("@#{k}", v) unless v.nil?
               end
           end
        end
        
        # The name of the dataset used in the evaluation
        # @return [String]
        attr_accessor :datasetName

        # The column targeted for prediction
        # @return [String] 
        attr_accessor :targetColumn

        # The details of the winning algorithm
        # @return [NexosisApi::AlgorithmSelection]
        attr_accessor :championContest
    end
end
