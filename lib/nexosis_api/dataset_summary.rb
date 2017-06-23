module NexosisApi
    # class to hold the parsed results of a dataset
    class DatasetSummary
        def initialize(data_hash)
            data_hash.each do |k,v|
                if(k == "dataSetName")
                    @dataset_name = v unless v.nil?
                end
            end
        end
    
        # The name of the dataset uploaded and saved
        attr_accessor :dataset_name
    end
end