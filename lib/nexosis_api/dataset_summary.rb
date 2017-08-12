module NexosisApi
    # class to hold the parsed results of a dataset
    class DatasetSummary
        def initialize(data_hash)
            data_hash.each do |k,v|
                if(k == "dataSetName")
                    @dataset_name = v unless v.nil?
                elsif(k == "columns")
                    columns = []
                    next if v.nil?
                    v.keys.each do |col_key|
                        columns << NexosisApi::Column.new(col_key, v[col_key])
                    end
                    @column_metadata = columns
                end
            end
        end
    
        # The name of the dataset uploaded and saved
        # @return [String]
        attr_accessor :dataset_name

        # Descriptive information about the columns
        # @return [Array of NexosisApi::Column]
        attr_accessor :column_metadata
    end
end