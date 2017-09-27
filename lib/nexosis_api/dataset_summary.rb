module NexosisApi
  # class to hold the parsed results of a dataset
  class DatasetSummary
    def initialize(data_hash)
      data_hash.each do |k, v|
        if (k == 'dataSetName')
          @dataset_name = v unless v.nil?
        elsif (k == 'columns')
          @column_metadata = columns.reject { |_key, value| value.nil? }
                                    .map do |col_key, col_val|
                                      NexosisApi::Column.new(col_key, col_val[col_key])
                                    end
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
